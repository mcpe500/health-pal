// config.js
module.exports = {
    API_BASE_URL: 'http://localhost:8080', // Your Go backend URL
    // Mock Google ID Token for testing purposes.
    // In a real scenario, you would obtain a valid ID token from Google's OAuth 2.0 flow.
    // For testing, you can use a JWT generator to create a token that passes basic validation
    // and has the necessary claims (sub, email, name, picture).
    // IMPORTANT: Replace "YOUR_MOCK_GOOGLE_ID_TOKEN" with an actual valid mock token for testing.
    MOCK_GOOGLE_ID_TOKEN: "YOUR_MOCK_GOOGLE_ID_TOKEN",
};