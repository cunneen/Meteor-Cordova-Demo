
    // Cordova
    console.log("Initializing Cordova");
    var cordovaRuntime = new CordovaRuntime(Assets);
 
    // Add the specific cordova file for android on cordova version 3.4.0
    cordovaRuntime.addFile("ios", "3.4.0", "ios-3.4.0/cordova.js");
    cordovaRuntime.addFile("ios", "3.4.0", "ios-3.4.0/cordova_plugins.js");
    // cordovaRuntime.addFile("android", "3.0.0", "plugin-3.0.0-android.js");

