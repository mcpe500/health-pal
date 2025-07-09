const axios = require('axios');
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Food Photo API', () => {
    let jwtToken;
    let uploadedPhotoId; // To store the ID of the uploaded photo for subsequent tests

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should upload a food photo successfully', async () => {
        const imagePath = path.resolve(__dirname, '../test_assets/test_food_photo.jpg'); // Path to a dummy image
        const formData = new FormData();
        formData.append('image', fs.createReadStream(imagePath));
        formData.append('description', 'Delicious test meal');
        formData.append('meal_type', 'dinner');

        const response = await axios.post(`${API_BASE_URL}/api/v1/food-photos/upload`, formData, {
            headers: {
                ...formData.getHeaders(),
                Authorization: `Bearer ${jwtToken}`
            }
        });

        expect(response.status).toBe(201); // 201 Created
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('image_url');
        expect(response.data.description).toBe('Delicious test meal');
        expect(response.data.meal_type).toBe('dinner');
        uploadedPhotoId = response.data.id; // Store photo ID
    });

    test('should retrieve food photo history for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/food-photos/history`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.length).toBeGreaterThan(0);
        const uploadedPhoto = response.data.find(photo => photo.id === uploadedPhotoId);
        expect(uploadedPhoto).toBeDefined();
        expect(uploadedPhoto.description).toBe('Delicious test meal');
    });

    test('should return 400 for uploading without an image file', async () => {
        const formData = new FormData();
        formData.append('description', 'No image here');

        await expect(axios.post(`${API_BASE_URL}/api/v1/food-photos/upload`, formData, {
            headers: {
                ...formData.getHeaders(),
                Authorization: `Bearer ${jwtToken}`
            }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized food photo upload', async () => {
        const imagePath = path.resolve(__dirname, '../test_assets/test_food_photo.jpg');
        const formData = new FormData();
        formData.append('image', fs.createReadStream(imagePath));

        await expect(axios.post(`${API_BASE_URL}/api/v1/food-photos/upload`, formData, {
            headers: { ...formData.getHeaders() } // No Authorization header
        })).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized food photo history access', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/food-photos/history`)).rejects.toHaveProperty('response.status', 401);
    });
});