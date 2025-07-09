const axios = require('axios');
const { API_BASE_URL, MOCK_GOOGLE_ID_TOKEN } = require('./config');

let globalJwtToken = ''; // Store JWT globally for reusability across test files

async function getAuthToken() {
    if (globalJwtToken) {
        return globalJwtToken;
    }
    try {
        const response = await axios.post(`${API_BASE_URL}/auth/google-login`, {
            id_token: MOCK_GOOGLE_ID_TOKEN,
        });
        globalJwtToken = response.data.token;
        return globalJwtToken;
    } catch (error) {
        console.error('Failed to obtain JWT token:', error.message);
        throw error;
    }
}

describe('Backend Auth API Tests', () => {
    beforeAll(async () => {
        // Ensure a fresh token for this test suite or use the global one
        await getAuthToken();
    });

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
        const response = await axios.post(`${API_BASE_URL}/auth/google-login`, {
            id_token: MOCK_GOOGLE_ID_TOKEN,
        });
        expect(response.status).toBe(200);
        expect(response.data).toHaveProperty('token');
        // Update global token if a new one is issued (though for mock it might be same)
        globalJwtToken = response.data.token;
        expect(globalJwtToken).not.toBeNull();
    });

    // Test case for Google Login - Existing User Success
    test('POST /auth/google-login for existing user should return a JWT', async () => {
        const response = await axios.post(`${API_BASE_URL}/auth/google-login`, {
            id_token: MOCK_GOOGLE_ID_TOKEN,
        });
        expect(response.status).toBe(200);
        expect(response.data).toHaveProperty('token');
        expect(response.data.token).not.toBeNull();
    });

    // Test case for accessing a protected endpoint with a valid JWT
    test('GET /api/v1/profile should return protected data with valid JWT', async () => {
        expect(globalJwtToken).not.toBe(''); // Ensure token is available
        const response = await axios.get(`${API_BASE_URL}/api/v1/profile`, {
            headers: {
                Authorization: `Bearer ${globalJwtToken}`,
            },
        });
        expect(response.status).toBe(200);
        expect(response.data).toHaveProperty('message');
        expect(response.data.message).toContain('Welcome');
    });

    // Negative test case: Invalid ID Token
    test('POST /auth/google-login with invalid ID token should return 401', async () => {
        await expect(axios.post(`${API_BASE_URL}/auth/google-login`, {
            id_token: 'INVALID_TOKEN',
        })).rejects.toHaveProperty('response.status', 401);
    });

    // Negative test case: Access protected endpoint without JWT
    test('GET /api/v1/profile without JWT should return 401', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/profile`)).rejects.toHaveProperty('response.status', 401);
    });

    // Negative test case: Access protected endpoint with expired JWT (requires a mock expired token)
    test('GET /api/v1/profile with expired JWT should return 401', async () => {
        const EXPIRED_JWT_TOKEN = "YOUR_EXPIRED_MOCK_TOKEN"; // REPLACE WITH AN ACTUAL EXPIRED MOCK TOKEN
        await expect(axios.get(`${API_BASE_URL}/api/v1/profile`, {
            headers: {
                Authorization: `Bearer ${EXPIRED_JWT_TOKEN}`,
            },
        })).rejects.toHaveProperty('response.status', 401);
    });
});

module.exports = { getAuthToken };