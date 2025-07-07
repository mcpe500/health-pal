const axios = require('axios');
const API_BASE_URL = 'http://localhost:8080'; // Ensure your Go backend is running

// Mock Google ID Token for testing purposes (same as in auth.test.js)
const MOCK_GOOGLE_ID_TOKEN = "YOUR_MOCK_GOOGLE_ID_TOKEN"; // REPLACE WITH A VALID MOCK TOKEN FOR TESTING

describe('Backend Deletion API Tests', () => {
  let userEmail = `testuser_${Date.now()}@example.com`; // Unique email for each test run
  let jwtToken = '';
  let otpSecret = ''; // This would typically be stored in the DB, but for testing, we'll simulate

  beforeAll(async () => {
    // Ensure a user exists for deletion tests
    try {
      const authResponse = await axios.post(`${API_BASE_URL}/auth/google-login`, {
        id_token: MOCK_GOOGLE_ID_TOKEN,
      });
      jwtToken = authResponse.data.token;
      // For a real test, you'd fetch the user's email from the token or the response
      // For now, we'll assume a consistent email can be derived from the mock token.
      // If the mock token always creates/updates the same user, then this is fine.
      // Otherwise, you'd need to mock Google's response to give a specific email.
    } catch (error) {
      console.error('Failed to set up user for deletion tests:', error.message);
      throw error; // Re-throw to fail the test suite setup
    }
  });

  // Test case for requesting OTP (positive)
  test('POST /api/v1/delete-account/request-otp should send OTP', async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/api/v1/delete-account/request-otp`, {
        email: userEmail,
      }, {
        headers: {
          Authorization: `Bearer ${jwtToken}`,
        },
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('message', 'OTP sent successfully');
      // In a real scenario, you'd intercept the email here to get the OTP.
      // For this test, we assume the backend correctly generated and stored it.
      // You might need a way to retrieve it for the next step, e.g., via a test endpoint or mocking.
      // For now, let's generate a mock OTP for the next step.
      otpSecret = '123456'; // Simulate OTP received via email for testing
    } catch (error) {
      throw new Error(`Request OTP test failed: ${error.message}`);
    }
  });

  // Test case for verifying OTP and soft deleting account (positive)
  test('POST /api/v1/delete-account/verify-otp should verify OTP and soft delete account', async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/api/v1/delete-account/verify-otp`, {
        email: userEmail,
        otp: otpSecret,
      }, {
        headers: {
          Authorization: `Bearer ${jwtToken}`,
        },
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('message', 'Account successfully deleted');

      // Verify soft deletion (optional, but good practice)
      // This would require a backend endpoint to check user status, or direct DB access
      // For now, we rely on the API response.
    } catch (error) {
      throw new Error(`Verify OTP and delete account test failed: ${error.message}`);
    }
  });

  // Negative test case: Request OTP for non-existent user
  test('POST /api/v1/delete-account/request-otp for non-existent user should return 404', async () => {
    try {
      await axios.post(`${API_BASE_URL}/api/v1/delete-account/request-otp`, {
        email: 'nonexistent@example.com',
      }, {
        headers: {
          Authorization: `Bearer ${jwtToken}`,
        },
      });
      fail('Expected 404 but received success');
    } catch (error) {
      expect(error.response.status).toBe(404);
      expect(error.response.data).toHaveProperty('error', 'user not found');
    }
  });

  // Negative test case: Verify OTP with incorrect OTP
  test('POST /api/v1/delete-account/verify-otp with incorrect OTP should return 401', async () => {
    try {
      await axios.post(`${API_BASE_URL}/api/v1/delete-account/verify-otp`, {
        email: userEmail,
        otp: 'WRONG_OTP',
      }, {
        headers: {
          Authorization: `Bearer ${jwtToken}`,
        },
      });
      fail('Expected 401 but received success');
    } catch (error) {
      expect(error.response.status).toBe(401);
      expect(error.response.data).toHaveProperty('error', 'invalid or expired OTP');
    }
  });

  // Negative test case: Verify OTP without requesting one
  test('POST /api/v1/delete-account/verify-otp without requesting OTP should return 400', async () => {
    // Need to ensure the user has no OTP set for this test
    // This might involve direct DB manipulation or a dedicated API endpoint for test setup
    const tempEmail = `tempuser_${Date.now()}@example.com`;
    await axios.post(`${API_BASE_URL}/auth/google-login`, { id_token: MOCK_GOOGLE_ID_TOKEN }); // Create a new user without OTP
    try {
      await axios.post(`${API_BASE_URL}/api/v1/delete-account/verify-otp`, {
        email: tempEmail,
        otp: '123456', // Some OTP
      }, {
        headers: {
          Authorization: `Bearer ${jwtToken}`,
        },
      });
      fail('Expected 400 but received success');
    } catch (error) {
      expect(error.response.status).toBe(400);
      expect(error.response.data).toHaveProperty('error', 'no OTP requested for this user');
    }
  });
});