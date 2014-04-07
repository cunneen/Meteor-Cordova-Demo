#!/bin/bash
# ==== Create cordova apps with different URLs for android and iOS
cordova create appFolder com.example.myApp "My App"

cd appFolder/

cordova platform add ios
cordova platform add android

# ==== make an after_prepare hook script
mkdir -p hooks/after_prepare
# ==== make an after 
touch hooks/after_prepare/change_my_configxml.sh
chmod 755 hooks/after_prepare/change_my_configxml.sh
# ==== start of hook script content ====
echo '#!/bin/bash

    echo "CORDOVA_VERSION: ${CORDOVA_VERSION}";
    echo "CORDOVA_PLATFORMS: ${CORDOVA_PLATFORMS}";
    echo "CORDOVA_PLUGINS: ${CORDOVA_PLUGINS}";
    echo "CORDOVA_HOOK: ${CORDOVA_HOOK}";
    echo "CORDOVA_CMDLINE: ${CORDOVA_CMDLINE}";
    # == put commands to make your config xml changes here ==
    # == replace these statement with your own ==

    if [ ! -f platforms/android/res/xml/config.xml ] 
    then 
      cp -v -f config.xml platforms/android/res/xml/config.xml; 
    fi
    if [[ ${CORDOVA_PLATFORMS} == android ]]; then
        sed -E "s/<content src=\"[^\"]+\"/<content src=\"http:\/\/www.google.com\/search\?q=Google%20Nexus%205\&amp;hl=xx-bork\"/" platforms/android/res/xml/config.xml > config.tmp && mv -f -v config.tmp platforms/android/res/xml/config.xml
    fi
    if [[ ${CORDOVA_PLATFORMS} == ios ]]; then
        sed -E "s/<content src=\"[^\"]+\"/<content src=\"http:\/\/www.google.com\/search\?q=iPad%20Retina\&amp;hl=xx-bork\"/"  config.xml > config.tmp && mv -f -v config.tmp config.xml
    fi
' > hooks/after_prepare/change_my_configxml.sh
# ==== end of hook script content ====

cordova prepare android
cordova build android
cordova emulate android

cordova prepare ios
cordova build ios
cordova emulate ios
