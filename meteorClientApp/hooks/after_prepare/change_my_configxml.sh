#!/bin/bash

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
            sed -E "s/<content src=\"[^\"]+\"/<content src=\"http:\/\/192.168.0.99:3000\?platform=android\&amp;cordova=3.4.0\"/" ${ANDROID_CONFIG_XML} > config.tmp && mv -f -v config.tmp ${ANDROID_CONFIG_XML}
        fi
        if [[ ${CORDOVA_PLATFORMS} == ios ]]; then
            sed -E "s/<content src=\"[^\"]+\"/<content src=\"http:\/\/localhost:3000\?platform=ios\&amp;cordova=3.4.0\"/" ${IOS_CONFIG_XML} > config.tmp && mv -f -v config.tmp ${IOS_CONFIG_XML}
        fi
    
