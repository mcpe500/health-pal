const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Health Plan API', () => {
    let jwtToken;

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should generate a new health plan successfully', async () => {
        const goals = "Weight Loss, More Energy";
        const response = await axios.post(`${API_BASE_URL}/api/v1/health-plan/generate`, {
            goals: goals
        }, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(201); // 201 Created
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('goal', goals);
        expect(response.data).toHaveProperty('plan_details');
        expect(response.data.plan_details).not.toBeNull();
    });

    test('should retrieve the latest health plan for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/health-plan`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(200);
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('goal');
        expect(response.data).toHaveProperty('plan_details');
    });

    test('should return 400 for invalid health plan generation request (e.g., missing goals)', async () => {
        const invalidGoals = ""; // Missing goals
        await expect(axios.post(`${API_BASE_URL}/api/v1/health-plan/generate`, {
            goals: invalidGoals
        }, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized health plan generation', async () => {
        const goals = "Build Muscle";
        await expect(axios.post(`${API_BASE_URL}/api/v1/health-plan/generate`, {
            goals: goals
        })).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to health plan', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/health-plan`)).rejects.toHaveProperty('response.status', 401);
    });
});