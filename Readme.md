Meteor Cordova Demo
===================

This is a demonstration of how to get a cordova app up and running and connecting to a meteor application.

Here are the commands used to create it:

```sh
cordova create app net.cunneen Test-cordova-runtime-app
# Creating a new cordova project with name "Test-cordova-runtime-app" and id "net.cunneen" at location "/Users/mikecunneen/Documents/Meteor/app"


cd app
cordova platforms add ios
# Creating ios project...
cordova platforms add android
# Creating android project...

cat config.xml | sed "s/index\.html/http:\/\/localhost:3000\?platform=ios\&cordova=3.4.0/" > merges/ios/config.xml  
cat config.xml | sed "s/index\.html/http:\/\/localhost:3000\?platform=android\&cordova=3.4.0/" > merges/android/config.xml
cordova prepare ios
cordova build

cd ..

meteor create test-cordova-runtime
# test-cordova-runtime: created.
# 
# To run your new app:
#    cd test-cordova-runtime
#    meteor

cd test-cordova-runtime/
mrt add cordova-runtime

# This takes a while, you should eventually get lots of output here, 
# finishing with:
# Ok, everything's ready. Here comes Meteor!
# 
# cordova-runtime: Use Cordova for runtime solution

mkdir server
cd server

# add cordova 
echo '
    // Cordova
    console.log("Initializing Cordova");
    var cordovaRuntime = new CordovaRuntime(Assets);
 
    // Add the specific cordova file for android on cordova version 3.4.0
    cordovaRuntime.addFile("ios", "3.4.0", "ios-3.4.0/cordova.js");
    cordovaRuntime.addFile("ios", "3.4.0", "ios-3.4.0/cordova_plugins.js");
    cordovaRuntime.addFile("android", "3.4.0", "android-3.4.0/cordova.js");
    cordovaRuntime.addFile("android", "3.4.0", "android-3.4.0/cordova_plugins.js");
    // cordovaRuntime.addFile("android", "3.0.0", "plugin-3.0.0-android.js");
' > ./cordova.js
cd ..
mkdir private
mkdir private/ios-3.4.0
mkdir private/android-3.4.0
cp -v ../app/platforms/ios/www/cordova*.js ./private/ios-3.4.0/
# ../app/platforms/ios/www/cordova.js -> ./private/ios-3.4.0/cordova.js
# ../app/platforms/ios/www/cordova_plugins.js -> ./private/ios-3.4.0/cordova_plugins.js

cp -v ../app/platforms/android/assets/www/cordova*.js ./private/ios-3.4.0/
# ../app/platforms/android/assets/www/cordova.js -> ./private/ios-3.4.0/cordova.js
# ../app/platforms/android/assets/www/cordova_plugins.js -> ./private/ios-3.4.0/cordova_plugins.js
```
