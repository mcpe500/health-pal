describe('Flutter App Navigation E2E Test', () => {
    beforeEach(async () => {
        // Assume user is logged in and on the home screen before each test
        const homeScreenTitle = await $('~Health Pal Home');
        await homeScreenTitle.waitForDisplayed({ timeout: 10000 });
        await expect(homeScreenTitle).toBeDisplayed();
    });

    it('should navigate to Health Plan screen and back', async () => {
        const healthPlanButton = await $('~Health Plan'); // Assuming accessibilityLabel
        await healthPlanButton.click();

        const healthPlanScreenTitle = await $('~Health Plan'); // Assuming accessibilityLabel
        await healthPlanScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(healthPlanScreenTitle).toBeDisplayed();

        // Navigate back to Home Screen
        const backButton = await $('~Back'); // Assuming a back button or system back navigation
        await backButton.click();

        const homeScreenTitle = await $('~Health Pal Home');
        await homeScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(homeScreenTitle).toBeDisplayed();
    });

    it('should navigate to Reminders screen and back', async () => {
        const remindersButton = await $('~Reminders'); // Assuming accessibilityLabel
        await remindersButton.click();

        const remindersScreenTitle = await $('~Reminders & Notifications'); // Assuming accessibilityLabel
        await remindersScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(remindersScreenTitle).toBeDisplayed();

        // Navigate back to Home Screen
        const backButton = await $('~Back');
        await backButton.click();

        const homeScreenTitle = await $('~Health Pal Home');
        await homeScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(homeScreenTitle).toBeDisplayed();
    });

    it('should navigate to Data Visualization screen and back', async () => {
        const visualizeDataButton = await $('~Visualize Data'); // Assuming accessibilityLabel
        await visualizeDataButton.click();

        const dataVisualizationScreenTitle = await $('~Data Visualization'); // Assuming accessibilityLabel
        await dataVisualizationScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(dataVisualizationScreenTitle).toBeDisplayed();

        // Navigate back to Home Screen
        const backButton = await $('~Back');
        await backButton.click();

        const homeScreenTitle = await $('~Health Pal Home');
        await homeScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(homeScreenTitle).toBeDisplayed();
    });

    it('should navigate to HP Data Collection screen and back', async () => {
        const hpDataCollectionButton = await $('~HP Data Collection'); // Assuming accessibilityLabel
        await hpDataCollectionButton.click();

        const hpDataCollectionScreenTitle = await $('~HP Data Collection'); // Assuming accessibilityLabel
        await hpDataCollectionScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(hpDataCollectionScreenTitle).toBeDisplayed();

        // Navigate back to Home Screen
        const backButton = await $('~Back');
        await backButton.click();

        const homeScreenTitle = await $('~Health Pal Home');
        await homeScreenTitle.waitForDisplayed({ timeout: 5000 });
        await expect(homeScreenTitle).toBeDisplayed();
    });
});