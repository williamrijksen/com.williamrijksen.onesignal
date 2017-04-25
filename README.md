# Titanium OneSignal [![Build Status](https://travis-ci.org/williamrijksen/com.williamrijksen.onesignal.svg?branch=master)](https://travis-ci.org/williamrijksen/com.williamrijksen.onesignal)

This module gives you the possibility to integrate OneSignal into you're Appcelerator Android or iOS-application. It's even possible to target people by registering tags.

## Generate Credentials

Before setting up the Titanium SDK, you must generate the appropriate credentials for the platform(s) you are releasing on:

- iOS - [Generate an iOS Push Certificate](https://documentation.onesignal.com/docs/generate-an-ios-push-certificate) 
- ANDROID - [Generate a Google Server API Key](https://documentation.onesignal.com/docs/generate-a-google-server-api-key)

## Follow Guide

### Setup

1. Integrate the module into the `modules` folder and define them into the `tiapp.xml` file:
    
    ```xml
    <modules>
      <module platform="iphone" version="1.6.0">com.williamrijksen.onesignal</module>
      <module platform="android" version="1.5.0">com.williamrijksen.onesignal</module>
    </modules>
    ```
1. Configure your app into the App Settings panel for the right Platform (Android and/or iOS).
1. To use OneSignal on iOS devices, register the OneSignal-appId into  `tiapp.xml`:
    
    ```xml
    <property name="OneSignal_AppID" type="string">[App-id]</property>
    ``` 
1. To use OneSignal on Android devices, register some meta-data as well: 
    
    ```xml
    <meta-data android:name="com.google.android.gms.version"
                   android:value="@integer/google_play_services_version" />
    <meta-data android:name="onesignal_app_id"
                   android:value="[App-id]" />
    <meta-data android:name="onesignal_google_project_number"
                   android:value="str:[Google project id]" />
    ```
1. To use rich notifications on iOS 10 you need to add an extension to your app.
   To do so see:
   - https://documentation.onesignal.com/docs/ios-sdk-setup#section-1-add-notification-service-extension
   - http://docs.appcelerator.com/platform/latest/#!/guide/Creating_iOS_Extensions_-_Siri_Intents

### Usage
1. Register device for Push Notifications
   
   ```js
        // This registers your device automatically into OneSignal
       var onesignal = require('com.williamrijksen.onesignal');
   ```
1. To add the possibility to target people for notifications, send a tag:
   
   ```js
       onesignal.sendTag({ key: 'foo', value: 'bar' });
   ```
1. Delete tag:
   
   ```js
       onesignal.deleteTag({ key: 'foo' });
   ```
1. Get tags:

    ```js
        onesignal.getTags(function(e) {
            if (!e.success) {
                Ti.API.error("Error: " + e.error);
                return
            }
            
            Ti.API.info(Ti.Platform.osname === "iphone"? e.results : JSON.parse(e.results));
        });
    ```   
1. IdsAvailable (iOS-only for now):

    ```js
        onesignal.idsAvailable(function(e) {
            //pushToken will be nil if the user did not accept push notifications
            alert(e);
        });
    ```   
1. postNotification (iOS-only for now):

    ```js
        //You can use idsAvailable for retrieving a playerId
        onesignal.postNotification({
            message:'Titanium test message',
            playerIds:["00000000-0000-0000-0000-000000000000"]
        });
    ```   
1. Set log level (iOS-only for now):

    ```js
        onesignal.setLogLevel({
            logLevel: onesignal.LOG_LEVEL_DEBUG,
            visualLevel: onesignal.LOG_LEVEL_NONE
        });
    ```   
1. Receive notifications callback: (does not work on iOS when the app is closed (swiped away). But works fine when the app is running on background)
   Opened:

    ```js
    onesignal.addEventListener('notificationOpened', function (evt) {
        alert(evt);
        if (evt) {
            var title = '';
            var content = '';
            var data = {};

            if (evt.title) {
                title = evt.title;
            }

            if (evt.body) {
                content = evt.body;
            }

            if (evt.additionalData) {
                if (Ti.Platform.osname === 'android') {
                    // Android receives it as a JSON string
                    data = JSON.parse(evt.additionalData);
                } else {
                    data = evt.additionalData;
                }
            }
        }
        alert("Notification opened! title: " + title + ', content: ' + content + ', data: ' + evt.additionalData);
    });
    ```

1. Received:

   ```js
   onesignal.addEventListener('notificationReceived', function(evt) {
       console.log(' ***** Received! ' + JSON.stringify(evt));
   });
   ```

Cheers!
