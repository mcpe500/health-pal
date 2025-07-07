const axios = require('axios');
const API_BASE_URL = 'http://localhost:8080'; // Ensure your Go backend is running

// Mock Google ID Token for testing purposes
// In a real scenario, you would obtain a valid ID token from Google's OAuth 2.0 flow
// For testing, you can use a JWT generator to create a token that passes basic validation
// and has the necessary claims (sub, email, name, picture)
const MOCK_GOOGLE_ID_TOKEN = "YOUR_MOCK_GOOGLE_ID_TOKEN"; // REPLACE WITH A VALID MOCK TOKEN FOR TESTING

describe('Backend Auth API Tests', () => {
  let jwtToken = '';

  // Test case for the /ping endpoint (basic connectivity check)
  test('GET /ping should return a 200 status and "pong" message', async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/ping`);
      expect(response.status).toBe(200);
      expect(response.data).toEqual({ message: 'pong' });
    } catch (error) {
      throw new Error(`Ping test failed: ${error.message}`);
    }
  });

  // Test case for Google Login - New User Success
  test('POST /auth/google-login should create a new user and return a JWT', async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/auth/google-login`, {
        id_token: MOCK_GOOGLE_ID_TOKEN,
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('token');
      jwtToken = response.data.token; // Store JWT for subsequent tests
      expect(jwtToken).not.toBeNull();
    } catch (error) {
      throw new Error(`Google login new user test failed: ${error.message}`);
    }
  });

  // Test case for Google Login - Existing User Success
  test('POST /auth/google-login for existing user should return a JWT', async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/auth/google-login`, {
        id_token: MOCK_GOOGLE_ID_TOKEN, // Use the same mock token for existing user
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('token');
      expect(response.data.token).not.toBeNull();
    } catch (error) {
      throw new Error(`Google login existing user test failed: ${error.message}`);
    }
  });

  // Test case for accessing a protected endpoint with a valid JWT
  test('GET /api/v1/profile should return protected data with valid JWT', async () => {
    if (!jwtToken) {
      throw new Error('JWT token not obtained from previous login test.');
    }
    try {
      const response = await axios.get(`${API_BASE_URL}/api/v1/profile`, {
        headers: {
          Authorization: `Bearer ${jwtToken}`,
        },
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('message');
      expect(response.data.message).toContain('Welcome');
    } catch (error) {
      throw new Error(`Protected data access test failed: ${error.message}`);
    }
  });

  // Negative test case: Invalid ID Token
  test('POST /auth/google-login with invalid ID token should return 401', async () => {
    try {
      await axios.post(`${API_BASE_URL}/auth/google-login`, {
        id_token: 'INVALID_TOKEN',
      });
      // If the request succeeds, fail the test
      fail('Expected 401 but received success');
    } catch (error) {
      expect(error.response.status).toBe(401);
      expect(error.response.data).toHaveProperty('error');
    }
  });

  // Negative test case: Access protected endpoint without JWT
  test('GET /api/v1/profile without JWT should return 401', async () => {
    try {
      await axios.get(`${API_BASE_URL}/api/v1/profile`);
      fail('Expected 401 but received success');
    } catch (error) {
      expect(error.response.status).toBe(401);
      expect(error.response.data).toHaveProperty('error');
    }
  });

  // Negative test case: Access protected endpoint with expired JWT (requires a mock expired token)
  test('GET /api/v1/profile with expired JWT should return 401', async () => {
    // For a real test, you'd generate an expired token here
    const EXPIRED_JWT_TOKEN = "YOUR_EXPIRED_MOCK_TOKEN"; // REPLACE WITH AN ACTUAL EXPIRED MOCK TOKEN
    try {
      await axios.get(`${API_BASE_URL}/api/v1/profile`, {
        headers: {
          Authorization: `Bearer ${EXPIRED_JWT_TOKEN}`,
        },
      });
      fail('Expected 401 but received success');
    } catch (error) {
      expect(error.response.status).toBe(401);
      expect(error.response.data).toHaveProperty('error');
    }
  });
});