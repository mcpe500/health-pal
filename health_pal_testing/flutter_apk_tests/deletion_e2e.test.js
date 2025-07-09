describe('Flutter App Account Deletion E2E Test', () => {
    it('should allow user to request and verify OTP for account deletion', async () => {
        // Assume user is logged in and on the home screen
        // Navigate to the home screen if not already there (could be part of a beforeEach or a previous test)
        // For this test, we assume a user is already logged in for simplicity.

        // Click on "Request Account Deletion OTP" button
        const requestOtpButton = await $('~Request Account Deletion OTP'); // Assuming accessibilityLabel
        await requestOtpButton.click();

        // Verify message indicating OTP sent
        const otpSentMessage = await $('~OTP sent'); // Assuming accessibilityLabel for a message like "OTP sent to..."
        await otpSentMessage.waitForDisplayed({ timeout: 10000 });
        await expect(otpSentMessage).toBeDisplayed();

        // Click on "Verify OTP & Delete Account" button to open the dialog
        const verifyDeleteButton = await $('~Verify OTP & Delete Account'); // Assuming accessibilityLabel
        await verifyDeleteButton.click();

        // Interact with the OTP dialog
        const otpInputDialog = await $('~Enter OTP'); // Assuming accessibilityLabel for the dialog title or input field
        await otpInputDialog.waitForDisplayed({ timeout: 5000 });
        await expect(otpInputDialog).toBeDisplayed();

        // Type a dummy OTP (in a real scenario, this would be retrieved from a test email or log)
        const otpInput = await $('android.widget.EditText'); // Assuming it's an EditText field
        await otpInput.setValue('123456'); // Replace with a valid dummy OTP

        // Click "Verify & Delete" button in the dialog
        const confirmVerifyDeleteButton = await $('~Verify & Delete'); // Assuming accessibilityLabel
        await confirmVerifyDeleteButton.click();

        // Verify success message and redirection to login screen
        const accountDeletedMessage = await $('~Account successfully deleted'); // Assuming accessibilityLabel
        await accountDeletedMessage.waitForDisplayed({ timeout: 10000 });
        await expect(accountDeletedMessage).toBeDisplayed();

        const loginScreenTitle = await $('~Health Pal Login'); // Assuming accessibilityLabel
        await loginScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(loginScreenTitle).toBeDisplayed();
    });
});