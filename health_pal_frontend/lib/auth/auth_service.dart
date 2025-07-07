import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:health_pal_frontend/utils/secure_storage.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SecureStorage _secureStorage = SecureStorage();
  final ApiClient _apiClient = ApiClient();

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID Token from Google.');
      }

      // Send ID token to backend
      final response = await _apiClient.post(
        '/auth/google-login',
        {'id_token': idToken},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String jwtToken = data['token'];
        await _secureStorage.saveJwtToken(jwtToken);
        return jwtToken;
      } else {
        throw Exception(
            'Backend authentication failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow; // Re-throw the exception for UI to handle
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _secureStorage.deleteJwtToken();
  }

  Future<String?> getJwtToken() async {
    return await _secureStorage.getJwtToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getJwtToken();
    // Basic check: token exists. More robust check would involve token validation on backend.
    return token != null;
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}