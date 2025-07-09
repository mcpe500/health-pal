const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Steps API', () => {
    let jwtToken;
    const testDate = new Date().toISOString().split('T')[0]; // Current date in YYYY-MM-DD format

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should record new steps for a user', async () => {
        const stepsData = {
            date: testDate,
            steps_count: 5000
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/steps`, stepsData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data.message).toBe('Steps recorded successfully');
    });

    test('should update existing steps for the same user and date', async () => {
        const updatedStepsData = {
            date: testDate,
            steps_count: 7500
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/steps`, updatedStepsData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data.message).toBe('Steps updated successfully');
    });

    test('should retrieve step history for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/steps/history`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.length).toBeGreaterThan(0);
        const latestEntry = response.data.find(entry => entry.date === testDate);
        expect(latestEntry).toBeDefined();
        expect(latestEntry.steps_count).toBe(7500); // Verify with updated value
    });

    test('should return 400 for invalid steps input', async () => {
        const invalidStepsData = {
            date: testDate,
            steps_count: -100 // Invalid steps count
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/steps`, invalidStepsData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized access to record steps', async () => {
        const stepsData = {
            date: testDate,
            steps_count: 1000
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/steps`, stepsData)).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to get step history', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/steps/history`)).rejects.toHaveProperty('response.status', 401);
    });
});