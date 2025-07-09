const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Sitting Time API', () => {
    let jwtToken;
    const testDate = new Date().toISOString().split('T')[0]; // Current date in YYYY-MM-DD format

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should record new sitting time for a user', async () => {
        const sittingTimeData = {
            date: testDate,
            duration_minutes: 120
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/sitting-times`, sittingTimeData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data.message).toBe('Sitting time recorded successfully');
    });

    test('should update existing sitting time for the same user and date', async () => {
        const updatedSittingTimeData = {
            date: testDate,
            duration_minutes: 180
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/sitting-times`, updatedSittingTimeData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data.message).toBe('Sitting time updated successfully');
    });

    test('should retrieve sitting time history for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/sitting-times/history`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });
        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.length).toBeGreaterThan(0);
        const latestEntry = response.data.find(entry => entry.date === testDate);
        expect(latestEntry).toBeDefined();
        expect(latestEntry.duration_minutes).toBe(180); // Verify with updated value
    });

    test('should return 400 for invalid sitting time input', async () => {
        const invalidSittingTimeData = {
            date: testDate,
            duration_minutes: -10 // Invalid duration
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/sitting-times`, invalidSittingTimeData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized access to record sitting time', async () => {
        const sittingTimeData = {
            date: testDate,
            duration_minutes: 60
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/sitting-times`, sittingTimeData)).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to get sitting time history', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/sitting-times/history`)).rejects.toHaveProperty('response.status', 401);
    });
});