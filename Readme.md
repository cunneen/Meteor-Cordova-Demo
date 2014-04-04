Meteor Cordova Demo
===================
## NOTE: THIS CURRENTLY DOESN'T WORK
This is a demonstration of how to get a cordova app up and running and connecting to a meteor application.

Here are the commands used to create it:

```sh
###### start of user-configurable stuff ####
export APPFOLDERNAME=app
export APPNAME=Test-cordova-runtime-app
export APPPREFIXID=net.cunneen
export METEORFOLDERNAME=test-cordova-runtime
export METEORSERVERPROTOCOL=http
export METEORHOSTPORT=localhost:3000
##### end of user-configurable stuff ####
export CORDOVAVERSION=`cordova -v | cut -f1 -d"-"`

echo 'Now creating a meteor project...'`echo ${METEORFOLDERNAME}`
meteor create ${METEORFOLDERNAME}

cd ${METEORFOLDERNAME}
echo 'This next step takes a while, it downloads cordova-specific plugins for meteor'
mrt add cordova-runtime

# put the platform-specific cordova javascript files into appropriate folders on the server.
mkdir private
mkdir private/ios-${CORDOVAVERSION}
mkdir private/android-${CORDOVAVERSION}
mkdir server

cd ..

#Creating a new cordova project with name ${APPNAME} and id ${APPPREFIXID} at location ${APPFOLDERNAME}
cordova create ${APPFOLDERNAME} ${APPPREFIXID} ${APPNAME}

# again, looks like we need a nap here while we wait for cordova.
echo 'sleeping for 5 seconds...'
sleep 5

echo "======= start with cordova =============="
echo 'Creating ios and android cordova projects...'
cd ${APPFOLDERNAME}
cordova platforms add ios
cordova platforms add android

##### I Have to stop the script here and perform the next steps later ######
##### (some sort of race condition: it looks like cordova runs background tasks) ######
echo '... I shouldnt have to do this, but it seems we need to wait a while for cordova to finish. Sleeping for 10 seconds.'
sleep 10

echo 'putting appropriate URLs into the cordova app config.xml files...'
mkdir -p merges/ios
mkdir -p merges/android

mkdir hooks/after_prepare
echo "sed \"s/index\.html/${METEORSERVERPROTOCOL}:\/\/${METEORHOSTPORT}\?platform=android\&amp;cordova=${CORDOVAVERSION}/\" platforms/android/res/xml/config.xml > config.tmp && mv -f -v config.tmp platforms/android/res/xml/config.xml" > hooks/after_prepare/01_fix_android_contentsrc.sh
chmod 755 hooks/after_prepare/01_fix_android_contentsrc.sh

echo "sed \"s/index\.html/${METEORSERVERPROTOCOL}:\/\/${METEORHOSTPORT}\?platform=ios\&amp;cordova=${CORDOVAVERSION}/\" platforms/android/res/xml/config.xml > config.tmp && mv -f -v config.tmp platforms/ios/www/config.xml" > hooks/after_prepare/01_fix_ios_contentsrc.sh
chmod 755 hooks/after_prepare/02_fix_ios_contentsrc.sh

cordova prepare
cordova build

echo '... I shouldnt have to do this, but it seems we need to wait a while for cordova to finish. Sleeping for 10 seconds.'
sleep 10

echo "======= done with cordova =============="
echo "copying files from cordova to meteor server..."

echo "======= now copying stuff from cordova to meteor ====="
cp -v platforms/ios/www/cordova*.js ../${METEORFOLDERNAME}/private/ios-${CORDOVAVERSION}/

cp -v platforms/android/assets/www/cordova*.js ../${METEORFOLDERNAME}/private/android-${CORDOVAVERSION}/


# Tell our server where weve put the appropriate cordova scripts, so when the app client
# asks for them it serves them up. 
echo -e "// Cordova \n\
    console.log(\"Initializing Cordova Runtime on the server\"); \n\
    var cordovaRuntime = new CordovaRuntime(Assets); \n\
    cordovaRuntime.addFile(\"ios\", \"${CORDOVAVERSION}\", \"ios-${CORDOVAVERSION}/cordova.js\"); \n\
    cordovaRuntime.addFile(\"ios\", \"${CORDOVAVERSION}\", \"ios-${CORDOVAVERSION}/cordova_plugins.js\"); \n\
    cordovaRuntime.addFile(\"android\", \"${CORDOVAVERSION}\", \"android-${CORDOVAVERSION}/cordova.js\"); \n\
    cordovaRuntime.addFile(\"android\", \"${CORDOVAVERSION}\", \"android-${CORDOVAVERSION}/cordova_plugins.js\"); \n\
" > ../${METEORFOLDERNAME}/server/cordova.js
```
