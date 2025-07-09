export const config: WebdriverIO.Config = {
    //
    // ====================
    // Runner Configuration
    // ====================
    // WebdriverIO allows it to run your tests in arbitrary locations over the network.
    // However, it is recommended to run it in a local environment or attach a remote device
    // for local testing purposes.
    runner: 'local',
    //
    // =====================
    // A framework you want to use
    // =====================
    // WebdriverIO supports various frameworks like Mocha, Jasmine, and Cucumber.
    // You can configure your framework here.
    framework: 'mocha',
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000,
    },
    //
    // =====================
    // Reporters
    // =====================
    // Define reporters here.
    reporters: ['junit'],
    //
    // =====================
    // Services
    // =====================
    // Define services here.
    services: [
        ['appium', {
            command: 'appium',
        }]
    ],
    //
    // =====================
    // Capabilities
    // =====================
    // Define your capabilities here.
    capabilities: [{
        platformName: 'Android',
        'appium:deviceName': 'emulator-5554', // Replace with your emulator/device name
        'appium:automationName': 'UiAutomator2',
        'appium:app': '../health_pal_frontend/build/app/outputs/flutter-apk/app-release.apk', // Path to your built APK
        'appium:noReset': true,
        'appium:fullReset': false,
    }],
    //
    // =====================
    // Test Files
    // =====================
    // Define test files here.
    specs: [
        './flutter_apk_tests/**/*.js',
        './flutter_apk_tests/**/*.ts'
    ],
    //
    // =====================
    // WebdriverIO Logging
    // =====================
    // Set the log level.
    logLevel: 'info',
    //
    // =====================
    // Hooks
    // =====================
    // Define your hooks here.
    onPrepare: function (config, capabilities) {
        console.log('Test suite starting...');
    },
    onComplete: function(exitCode, stats, duration) {
        console.log('Test suite finished!');
    },
};
