###### start of user-configurable stuff ####
export APPFOLDERNAME=meteorClientApp
export APPNAME='Meteor Client App'
export APPPREFIXID=net.cunneen.app
export METEORFOLDERNAME=meteor-mobile-app-server
export METEORSERVERPROTOCOL=http
# NOTE: If you're using localhost, you have to edit the hook script URL for android
# to be 10.0.0.22 instead of localhost.
export METEORHOSTPORT=localhost:3000
export HOOKSCRIPT=hooks/after_prepare/change_my_configxml.sh
##### config.xml file locations.
## NOTE: THESE ALSO NEED TO BE CHANGED IN THE HOOKS SCRIPT STRING
export ANDROID_CONFIG_XML="platforms/android/res/xml/config.xml"
export IOS_CONFIG_XML="config.xml"

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
cordova create ${APPFOLDERNAME} ${APPPREFIXID} "${APPNAME}"

# again, looks like we need a nap here while we wait for cordova.
echo 'sleeping for 5 seconds...'
sleep 5

echo "======= start with cordova =============="
echo 'Creating ios and android cordova projects...'
cd ${APPFOLDERNAME}
cordova platforms add ios
cordova platforms add android

##### (avoid some sort of race condition: it looks like cordova runs background tasks) ######
echo '... I shouldnt have to do this, but it seems we need to wait a while for cordova to finish. Sleeping for 10 seconds.'
sleep 10

echo 'putting appropriate URLs into the cordova app config.xml files...'

    # ==== make an after_prepare hook script
    mkdir -p `dirname ${HOOKSCRIPT}`
    # ==== make an after 
    touch ${HOOKSCRIPT}
    # ==== start of hook script content ====
    echo '#!/bin/bash

        echo "CORDOVA_VERSION: ${CORDOVA_VERSION}";
        echo "CORDOVA_PLATFORMS: ${CORDOVA_PLATFORMS}";
        echo "CORDOVA_PLUGINS: ${CORDOVA_PLUGINS}";
        echo "CORDOVA_HOOK: ${CORDOVA_HOOK}";
        echo "CORDOVA_CMDLINE: ${CORDOVA_CMDLINE}";
        export ANDROID_CONFIG_XML="platforms/android/res/xml/config.xml"
        export IOS_CONFIG_XML="config.xml"
        # == put commands to make your config xml changes here ==
        # == replace these statement with your own ==

        if [ ! -f platforms/android/res/xml/config.xml ] 
        then 
          cp -v -f config.xml platforms/android/res/xml/config.xml; 
        fi
        if [[ ${CORDOVA_PLATFORMS} == android ]]; then
            sed -E "s/<content src=\"[^\"]+\"/<content src=\"METEORSERVERPROTOCOL:\/\/METEORHOSTPORT\?platform=android\&amp;cordova=CORDOVAVERSION\"/" ${ANDROID_CONFIG_XML} > config.tmp && mv -f -v config.tmp ${ANDROID_CONFIG_XML}
        fi
        if [[ ${CORDOVA_PLATFORMS} == ios ]]; then
            sed -E "s/<content src=\"[^\"]+\"/<content src=\"METEORSERVERPROTOCOL:\/\/METEORHOSTPORT\?platform=ios\&amp;cordova=CORDOVAVERSION\"/" ${IOS_CONFIG_XML} > config.tmp && mv -f -v config.tmp ${IOS_CONFIG_XML}
        fi
    ' > ${HOOKSCRIPT}
    # ====== the actual hook script is finished here but we need a couple of substitutions
    # modify hook script to replace placeholders with meteor URLs
    #ios
    sed -e "s/METEORSERVERPROTOCOL/${METEORSERVERPROTOCOL}/g" -e "s/METEORHOSTPORT/${METEORHOSTPORT}/g" -e "s/CORDOVAVERSION/${CORDOVAVERSION}/g"  ${HOOKSCRIPT} > ${HOOKSCRIPT}.tmp && mv -f -v ${HOOKSCRIPT}.tmp  ${HOOKSCRIPT}
    chmod 755 ${HOOKSCRIPT}
    # ==== end of hook script content ====

cordova prepare android
cordova build android

cordova prepare ios
cordova build ios
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

# start our server in the background
cd ../${METEORFOLDERNAME}
mrt 2>&1 &

# start our apps
cd ../${APPFOLDERNAME}
cordova emulate android
cordova emulate ios