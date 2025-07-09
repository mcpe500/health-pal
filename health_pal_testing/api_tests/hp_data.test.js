const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('HP Data API', () => {
    let jwtToken;
    const testDate = new Date().toISOString().split('T')[0]; // Current date in YYYY-MM-DD format

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should upload HP health data successfully', async () => {
        const hpData = [{
            data_type: "STEPS",
            value: 1000,
            unit: "count",
            timestamp: new Date().toISOString()
        },
        {
            data_type: "HEART_RATE",
            value: 75,
            unit: "bpm",
            timestamp: new Date().toISOString()
        }];

        const response = await axios.post(`${API_BASE_URL}/api/v1/hp-data/upload`, hpData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(201); // 201 Created
        expect(response.data.message).toBe('Health data uploaded successfully');
    });

    test('should retrieve HP health data history for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/hp-data/history`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.length).toBeGreaterThan(0);
        expect(response.data[0]).toHaveProperty('data_type');
        expect(response.data[0]).toHaveProperty('value');
    });

    test('should retrieve HP health data history filtered by data type', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/hp-data/history?data_type=STEPS`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.every(entry => entry.data_type === 'STEPS')).toBe(true);
    });

    test('should return 400 for invalid HP data upload request', async () => {
        const invalidHpData = [{
            data_type: "INVALID_TYPE", // Invalid type
            value: "abc", // Invalid value
            unit: "unit",
            timestamp: "invalid-date"
        }];

        await expect(axios.post(`${API_BASE_URL}/api/v1/hp-data/upload`, invalidHpData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized HP data upload', async () => {
        const hpData = [{
            data_type: "STEPS",
            value: 100,
            unit: "count",
            timestamp: new Date().toISOString()
        }];
        await expect(axios.post(`${API_BASE_URL}/api/v1/hp-data/upload`, hpData)).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to HP data history', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/hp-data/history`)).rejects.toHaveProperty('response.status', 401);
    });
});