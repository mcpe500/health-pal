const axios = require('axios');
const { API_BASE_URL } = require('./config');
const { getAuthToken } = require('./auth.test'); // Assuming auth.test.js provides a way to get a valid JWT

describe('Reminders API', () => {
    let jwtToken;
    const scheduledTime = new Date(Date.now() + 60 * 60 * 1000).toISOString(); // 1 hour from now

    beforeAll(async () => {
        jwtToken = await getAuthToken(); // Get a valid JWT before all tests
    });

    test('should schedule a custom reminder successfully', async () => {
        const reminderData = {
            scheduled_time: scheduledTime,
            type: 'custom',
            custom_message: 'Remember to drink water!'
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/reminders/schedule`, reminderData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(201); // 201 Created
        expect(response.data).toHaveProperty('message', 'Reminder scheduled successfully');
        expect(response.data).toHaveProperty('reminder_id');
    });

    test('should schedule a morning check-in reminder successfully', async () => {
        const reminderData = {
            scheduled_time: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(), // 2 hours from now
            type: 'morning_checkin'
        };
        const response = await axios.post(`${API_BASE_URL}/api/v1/reminders/schedule`, reminderData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(201);
        expect(response.data).toHaveProperty('message', 'Reminder scheduled successfully');
    });

    test('should retrieve scheduled reminders for the user', async () => {
        const response = await axios.get(`${API_BASE_URL}/api/v1/reminders`, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        });

        expect(response.status).toBe(200);
        expect(response.data).toBeInstanceOf(Array);
        expect(response.data.length).toBeGreaterThan(0);
        const customReminder = response.data.find(r => r.reminder_text === 'Remember to drink water!');
        expect(customReminder).toBeDefined();
        expect(customReminder.status).toBe('pending');
    });

    test('should return 400 for invalid reminder scheduling request (e.g., missing scheduled_time)', async () => {
        const invalidReminderData = {
            type: 'custom',
            custom_message: 'Invalid test'
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/reminders/schedule`, invalidReminderData, {
            headers: { Authorization: `Bearer ${jwtToken}` }
        })).rejects.toHaveProperty('response.status', 400);
    });

    test('should return 401 for unauthorized reminder scheduling', async () => {
        const reminderData = {
            scheduled_time: scheduledTime,
            type: 'custom',
            custom_message: 'Unauthorized test'
        };
        await expect(axios.post(`${API_BASE_URL}/api/v1/reminders/schedule`, reminderData)).rejects.toHaveProperty('response.status', 401);
    });

    test('should return 401 for unauthorized access to reminders history', async () => {
        await expect(axios.get(`${API_BASE_URL}/api/v1/reminders`)).rejects.toHaveProperty('response.status', 401);
    });
});