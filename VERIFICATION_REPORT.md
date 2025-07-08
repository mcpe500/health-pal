# Health Pal Application - Functional Verification Report

This report outlines the functional verification steps for each feature of the Health Pal application. Please follow these steps and update the "Status" for each feature. If any issues are found, please describe them in the "Issues Found" section.

## Verification Instructions

For each feature, follow the outlined steps using the Flutter frontend and interacting with the backend (implicitly via the frontend).

### Key:
*   **Status:**
    *   `PENDING`: Verification not yet performed.
    *   `VERIFIED`: Feature works as expected.
    *   `ISSUES`: Issues found, details in "Issues Found" section.

---

## 1. User Authentication and Login (Ticket 1)

*   **Description:** Users can sign in using their Google account. Protected API routes are accessible after successful authentication.
*   **Verification Steps:**
    1.  Launch the Flutter app.
    2.  On the login screen, tap "Sign in with Google".
    3.  Complete the Google sign-in process.
    4.  Verify that you are redirected to the home screen.
    5.  Check the "Protected data" message on the home screen to ensure it shows a success message (e.g., "Welcome, User X! This is a protected route.").
    6.  Log out from the app.
    7.  Attempt to access protected routes (if possible manually, otherwise implicitly by trying to log in again).
*   **Status:** PENDING
*   **Issues Found:**

---

## 2. Step Tracking (Ticket 2)

*   **Description:** Users can record their daily step count, and view historical step data.
*   **Verification Steps:**
    1.  On the home screen, enter a number in the "Enter daily steps" field.
    2.  Tap "Record Steps".
    3.  Verify a success message appears.
    4.  Check the "Step History" list to ensure the new entry appears with the correct date and step count.
    5.  Add another entry for the same day with a different step count. Verify the existing entry is updated.
*   **Status:** PENDING
*   **Issues Found:**

---

## 3. Sitting Time Tracking (Ticket 3)

*   **Description:** Users can record their daily sitting time in minutes, and view historical sitting time data.
*   **Verification Steps:**
    1.  On the home screen, enter a number in the "Enter daily sitting time (minutes)" field.
    2.  Tap "Record Sitting Time".
    3.  Verify a success message appears.
    4.  Check the "Sitting Time History" list to ensure the new entry appears with the correct date and duration.
    5.  Add another entry for the same day with a different duration. Verify the existing entry is updated.
*   **Status:** PENDING
*   **Issues Found:**

---

## 4. Food Photo Upload (Ticket 5)

*   **Description:** Users can upload food photos from their camera or gallery.
*   **Verification Steps:**
    1.  On the home screen, tap "Take Photo" or "Pick from Gallery".
    2.  Select or take an image.
    3.  Verify a success message appears.
    4.  Check the "Food Photo History" grid to ensure the uploaded photo appears.
*   **Status:** PENDING
*   **Issues Found:**

---

## 5. AI-Powered Food Analysis (Ticket 6)

*   **Description:** Users can request AI analysis of uploaded food photos to extract nutritional information.
*   **Verification Steps:**
    1.  Ensure you have at least one food photo uploaded (from step 4).
    2.  On the home screen, for an uploaded food photo, tap the "Analyze" button.
    3.  Verify a "Food photo analysis requested!" message appears.
    4.  Check the "Food Analysis History" list to see if the analysis result appears, showing detected items and calories. (Note: This might take a few moments for the backend to process the AI request).
*   **Status:** PENDING
*   **Issues Found:**

---

## 6. Nutrition Tracking (Ticket 7)

*   **Description:** Aggregates nutrition data from AI analysis and allows manual entry of nutrition.
*   **Verification Steps:**
    1.  Perform a food analysis (from step 5) to generate some AI-derived nutrition data.
    2.  On the home screen, verify the "Daily Nutrition Summary" section (if implemented on home screen) or navigate to a dedicated nutrition summary screen (if exists) to see aggregated data.
    3.  (If manual entry is on home screen) Enter values for manual calories, protein, carbs, and fats.
    4.  Tap "Log Manual Nutrition".
    5.  Verify a success message appears and the summary updates.
*   **Status:** PENDING
*   **Issues Found:**

---

## 7. Health Plan Generation (Ticket 8)

*   **Description:** Users can generate personalized health plans based on their goals and existing health data.
*   **Verification Steps:**
    1.  Navigate to the "Health Plan" screen.
    2.  Enter some health goals in the text field (e.g., "Weight Loss", "Muscle Gain").
    3.  Tap "Generate Health Plan".
    4.  Verify a "Health plan generated successfully!" message appears.
    5.  Review the displayed health plan details (summary, dietary recommendations, exercise suggestions, lifestyle tips) to ensure they are relevant to the goals.
*   **Status:** PENDING
*   **Issues Found:**

---

## 8. Gemini Integration for Reminders and Notifications (Ticket 9)

*   **Description:** Users can schedule reminders, and personalized reminder text is generated using Gemini.
*   **Verification Steps:**
    1.  Navigate to the "Reminders" screen.
    2.  Select a "Scheduled Time" using the date and time pickers.
    3.  Choose a "Reminder Type" (e.g., "morning_checkin", "exercise_reminder").
    4.  If "Custom Message" is selected, enter a message.
    5.  Tap "Schedule Reminder".
    6.  Verify a "Reminder scheduled successfully!" message appears.
    7.  Check the "Scheduled Reminders" list to see the new reminder.
    8.  (Optional, requires backend access/logs): Verify that the backend's reminder scheduler attempts to send an email notification when the scheduled time is reached.
*   **Status:** PENDING
*   **Issues Found:**

---

## 9. Data Visualization (Ticket 10)

*   **Description:** Visualizes health data (steps, sitting time, calories) using charts.
*   **Verification Steps:**
    1.  Navigate to the "Visualize Data" screen.
    2.  Select "Steps" from the dropdown. Verify the chart displays step data (if available).
    3.  Select "Sitting Time (minutes)" from the dropdown. Verify the chart displays sitting time data (if available).
    4.  Select "Calories" from the dropdown. Verify the chart displays calorie data (if available).
    5.  Check for appropriate messages if no data is available for a selected type.
*   **Status:** PENDING
*   **Issues Found:**

---

## 10. HP Data Collection (Ticket 11)

*   **Description:** Collects health data from the phone's health services (HealthKit/Google Fit) and uploads it to the backend.
*   **Verification Steps:**
    1.  Navigate to the "HP Data Collection" screen.
    2.  Tap "Collect & Upload Steps".
    3.  Grant necessary health permissions if prompted by your device.
    4.  Verify a success message appears (e.g., "Steps data collected and uploaded successfully!").
    5.  Repeat for "Collect & Upload Heart Rate", "Collect & Upload Body Mass Index", "Collect & Upload Height".
    6.  Verify appropriate messages for data collection status (success, no data, permission denied).
*   **Status:** PENDING
*   **Issues Found:**

---

## 11. Account Deletion

*   **Description:** Users can soft-delete their account via OTP verification (both web and API/Flutter).
*   **Verification Steps (Flutter App):**
    1.  On the home screen, tap "Request Account Deletion OTP".
    2.  Verify a message indicating OTP sent to your email.
    3.  Retrieve the OTP from your email.
    4.  Tap "Verify OTP & Delete Account".
    5.  Enter the OTP in the dialog and tap "Verify & Delete".
    6.  Verify a success message appears and you are redirected to the login screen.
    7.  Attempt to log in with the deleted account (should fail).
*   **Status:** PENDING
*   **Issues Found:**