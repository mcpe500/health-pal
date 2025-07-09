describe('Flutter App Data Entry E2E Test', () => {
    beforeEach(async () => {
        // Ensure user is logged in and on the home screen before each test
        // This could involve a login helper function or assuming previous test handles login
        // For simplicity, we'll assume login is handled externally or by a previous test.
        // If not logged in, these tests will likely fail.
        const homeScreenTitle = await $('~Health Pal Home');
        await homeScreenTitle.waitForDisplayed({ timeout: 10000 });
        await expect(homeScreenTitle).toBeDisplayed();
    });

    it('should allow user to record steps and view history', async () => {
        const stepsInput = await $('android.widget.EditText'); // Assuming the first EditText is for steps
        await stepsInput.setValue('5000');

        const recordStepsButton = await $('~Record Steps'); // Assuming accessibilityLabel
        await recordStepsButton.click();

        const successMessage = await $('~Steps recorded successfully'); // Assuming accessibilityLabel for a success message
        await successMessage.waitForDisplayed({ timeout: 5000 });
        await expect(successMessage).toBeDisplayed();

        // Verify history entry (might need to scroll or find specific element)
        const stepsHistory = await $('~5000 steps'); // Assuming accessibilityLabel for the history entry
        await expect(stepsHistory).toBeDisplayed();
    });

    it('should allow user to record sitting time and view history', async () => {
        // Assuming steps input is the first, sitting time is the second EditText
        const sittingTimeInput = await $$('android.widget.EditText')[1]; 
        await sittingTimeInput.setValue('120');

        const recordSittingTimeButton = await $('~Record Sitting Time'); // Assuming accessibilityLabel
        await recordSittingTimeButton.click();

        const successMessage = await $('~Sitting time recorded successfully');
        await successMessage.waitForDisplayed({ timeout: 5000 });
        await expect(successMessage).toBeDisplayed();

        const sittingTimeHistory = await $('~120 minutes');
        await expect(sittingTimeHistory).toBeDisplayed();
    });

    // Note: Water intake is not on the current home screen based on the provided code.
    // This test assumes a UI element for water intake will be added or accessed via navigation.
    // Skipping water intake test for now, or would require navigating to a different screen.

    it('should allow user to upload a food photo from gallery', async () => {
        const pickFromGalleryButton = await $('~Pick from Gallery'); // Assuming accessibilityLabel
        await pickFromGalleryButton.click();

        // Platform-specific interactions for image picker
        // This is highly dependent on the emulator/device and might require native UI automation.
        // For Android, it might involve selecting from recent images or navigating a gallery.
        // For simplicity, we'll assume the picker opens and an image is selected automatically or manually.
        // This part often needs to be mocked or handled with care in real E2E.

        // Example: If a system dialog appears, you might need to interact with it
        // await driver.pause(3000); // Wait for picker to open
        // const firstImage = await $('android.widget.ImageView'); // Example: find first image
        // await firstImage.click();

        const successMessage = await $('~Food photo uploaded successfully');
        await successMessage.waitForDisplayed({ timeout: 15000 }); // Longer timeout for file operations
        await expect(successMessage).toBeDisplayed();

        const foodPhotoHistory = await $('~Food Photo History'); // Assuming a section title for history
        await expect(foodPhotoHistory).toBeDisplayed();
    });

    it('should allow user to log manual nutrition data', async () => {
        // Assuming specific EditText fields for manual nutrition
        const caloriesInput = await $('~manualCaloriesInput'); // Replace with actual accessibilityLabel
        const proteinInput = await $('~manualProteinInput');
        const carbsInput = await $('~manualCarbsInput');
        const fatsInput = await $('~manualFatsInput');

        await caloriesInput.setValue('1500');
        await proteinInput.setValue('80');
        await carbsInput.setValue('200');
        await fatsInput.setValue('50');

        const logNutritionButton = await $('~Log Manual Nutrition'); // Assuming accessibilityLabel
        await logNutritionButton.click();

        const successMessage = await $('~Nutrition logged successfully');
        await successMessage.waitForDisplayed({ timeout: 5000 });
        await expect(successMessage).toBeDisplayed();

        const dailyNutritionSummary = await $('~Daily Nutrition Summary'); // Assuming a section title
        await expect(dailyNutritionSummary).toBeDisplayed();
        await expect(dailyNutritionSummary).toHaveTextContaining('1500'); // Verify calories in summary
    });
});