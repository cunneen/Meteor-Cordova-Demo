// Cordova 
    console.log("Initializing Cordova Runtime on the server"); 
    var cordovaRuntime = new CordovaRuntime(Assets); 
    cordovaRuntime.addFile("ios", "3.4.0", "ios-3.4.0/cordova.js"); 
    cordovaRuntime.addFile("ios", "3.4.0", "ios-3.4.0/cordova_plugins.js"); 
    cordovaRuntime.addFile("android", "3.4.0", "android-3.4.0/cordova.js"); 
    cordovaRuntime.addFile("android", "3.4.0", "android-3.4.0/cordova_plugins.js"); 

