const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Water Intake API', () => {
    let jwtToken;
    const testDate = new Date().toISOString().split('T')[0]; // Current date in YYYY-MM-DD format

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should record new water intake for a user', async () => {
        const waterIntakeData = {
            date: testDate,
            amount_ml: 2000
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/water-intakes`, waterIntakeData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data.message).toBe('Water intake recorded successfully');
    });

    test('should update existing water intake for the same user and date', async () => {
        const updatedWaterIntakeData = {
            date: testDate,
            amount_ml: 2500
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/water-intakes`, updatedWaterIntakeData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data.message).toBe('Water intake updated successfully');
    });

    test('should retrieve water intake history for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/water-intakes/history`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.length).toBeGreaterThan(0);
        const latestEntry = response.data.find(entry => entry.date === testDate);
        expect(latestEntry).toBeDefined();
        expect(latestEntry.amount_ml).toBe(2500); // Verify with updated value
    });

    test('should return 400 for invalid water intake input', async () => {
        const invalidWaterIntakeData = {
            date: testDate,
            amount_ml: -500 // Invalid amount
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/water-intakes`, invalidWaterIntakeData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized access to record water intake', async () => {
        const waterIntakeData = {
            date: testDate,
            amount_ml: 1000
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/water-intakes`, waterIntakeData)).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to get water intake history', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/water-intakes/history`)).rejects.toHaveProperty('response.status', 401);
    });
});