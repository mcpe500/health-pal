const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Food Analysis API', () => {
    let jwtToken;
    let foodPhotoId; // To store a dummy food photo ID for analysis

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests

        // To test food analysis, we first need a food photo to analyze.
        // In a real scenario, this would come from a previous photo upload test.
        // For now, we'll mock a food photo ID.
        // In a more integrated test, you'd upload a photo here.
        // For the purpose of this test, we'll assume a food photo with ID 1 exists for the user.
        // You might need to manually create a dummy food photo in your DB for initial testing.
        foodPhotoId = 1; 
    });

    test('should request food analysis for a given photo ID', async () => {
        const response = await axios.post(`${API_BASE_URL}/api/v1/food-photos/analyze`, {
            food_photo_id: foodPhotoId
        }, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(201); // 201 Created
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('detected_items');
        expect(response.data).toHaveProperty('total_calories');
        expect(response.data.total_calories).toBeGreaterThan(0);
    });

    test('should retrieve food analysis history for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/food-photos/analysis-history`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.length).toBeGreaterThan(0);
        const latestAnalysis = response.data.find(analysis => analysis.food_photo_id === foodPhotoId);
        expect(latestAnalysis).toBeDefined();
        expect(latestAnalysis).toHaveProperty('detected_items');
    });

    test('should return 400 for invalid food photo ID for analysis', async () => {
        await expect(axios.post(`${API_BASE_URL}/api/v1/food-photos/analyze`, {
            food_photo_id: 999999 // Non-existent ID
        }, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400); // Or 404 depending on backend
    });

    test('should return 401 for unauthorized food analysis request', async () => {
        await expect(axios.post(`${API_BASE_URL}/api/v1/food-photos/analyze`, {
            food_photo_id: foodPhotoId
        })).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to food analysis history', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/food-photos/analysis-history`)).rejects.toHaveProperty('response.status', 401);
    });
});