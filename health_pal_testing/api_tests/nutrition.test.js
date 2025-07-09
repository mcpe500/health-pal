const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Nutrition API', () => {
    let jwtToken;
    const testDate = new Date().toISOString().split('T')[0]; // Current date in YYYY-MM-DD format

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should log manual nutrition data successfully', async () => {
        const nutritionData = {
            record_date: testDate,
            total_calories: 2000.50,
            total_protein: 100.25,
            total_carbohydrates: 250.75,
            total_fats: 70.10,
            micronutrients_json: JSON.stringify({ "Vitamin C": "90mg", "Iron": "18mg" })
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/nutrition/manual-entry`, nutritionData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(201); // 201 Created
        expect(response.data.message).toBe('Nutrition data logged successfully');
    });

    test('should retrieve daily nutrition summary for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/nutrition/daily-summary?date=${testDate}`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(200);
        expect(response.data).toHaveProperty('record_date', `${testDate}T00:00:00Z`); // Date might be returned with time part
        expect(response.data.total_calories).toBeCloseTo(2000.50);
        expect(response.data.total_protein).toBeCloseTo(100.25);
        expect(response.data.total_carbohydrates).toBeCloseTo(250.75);
        expect(response.data.total_fats).toBeCloseTo(70.10);
        expect(JSON.parse(response.data.micronutrients_json)).toEqual({ "Vitamin C": "90mg", "Iron": "18mg" });
    });

    test('should return 400 for invalid manual nutrition data input', async () => {
        const invalidNutritionData = {
            record_date: testDate,
            total_calories: "invalid" // Invalid type
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/nutrition/manual-entry`, invalidNutritionData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized manual nutrition entry', async () => {
        const nutritionData = {
            record_date: testDate,
            total_calories: 100
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/nutrition/manual-entry`, nutritionData)).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to daily nutrition summary', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/nutrition/daily-summary?date=${testDate}`)).rejects.toHaveProperty('response.status', 401);
    });
});