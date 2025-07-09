describe('Flutter App Authentication E2E Test', () => {
    it('should allow user to login with Google and navigate to home screen', async () => {
        // Assume the app is launched and on the login screen
        // Click on the "Sign in with Google" button
        const signInButton = await $('~Sign in with Google'); // Assuming an accessibilityLabel
        await signInButton.click();

        // After clicking, a Google sign-in pop-up/webview might appear.
        // Automating this part is complex and often requires platform-specific handling
        // or pre-configured test accounts. For now, we'll assume a successful login
        // and proceed to verify the home screen.
        // In a real E2E test, you would need to interact with the native Google login UI.

        // Wait for the home screen to appear
        const homeScreenTitle = await $('~Health Pal Home'); // Assuming an accessibilityLabel for home screen title
        await homeScreenTitle.waitForDisplayed({ timeout: 15000 }); // Wait up to 15 seconds

        await expect(homeScreenTitle).toBeDisplayed();

        // Verify protected data message
        const protectedDataMessage = await $('~Protected data'); // Assuming an accessibilityLabel
        await protectedDataMessage.waitForDisplayed({ timeout: 5000 });
        await expect(protectedDataMessage).toBeDisplayed();
        await expect(protectedDataMessage).toHaveTextContaining('Welcome');
    });

    it('should allow user to logout from the home screen', async () => {
        // Assume user is already logged in and on the home screen
        // Click on the logout icon
        const logoutButton = await $('~Sign Out'); // Assuming an accessibilityLabel
        await logoutButton.click();

        // Verify that the app navigates back to the login screen
        const loginScreenTitle = await $('~Health Pal Login'); // Assuming an accessibilityLabel
        await loginScreenTitle.waitForDisplayed({ timeout: 10000 });
        await expect(loginScreenTitle).toBeDisplayed();
    });
});