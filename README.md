# Titanium OneSignal [![Build Status](https://travis-ci.org/williamrijksen/com.williamrijksen.onesignal.svg?branch=master)](https://travis-ci.org/williamrijksen/com.williamrijksen.onesignal)

This module gives you the possibility to integrate OneSignal into you're Appcelerator Android or iOS-application. It's even possible to target people by registering tags.

### Where to get it:
Please check https://github.com/williamrijksen/com.williamrijksen.onesignal/releases to download latest releases of the module.

## Generate Credentials

Before setting up the Titanium SDK, you must generate the appropriate credentials for the platform(s) you are releasing on:

- iOS - [Generate an iOS Push Certificate](https://documentation.onesignal.com/docs/generate-an-ios-push-certificate)
- ANDROID - [Generate a Google Server API Key](https://documentation.onesignal.com/docs/generate-a-google-server-api-key)

## Follow Guide

### Setup

1. Integrate the module into the `modules` folder and define them into the `tiapp.xml` file:

    ```xml
    <modules>
      <module platform="iphone">com.williamrijksen.onesignal</module>
      <module platform="android">com.williamrijksen.onesignal</module>
    </modules>
    ```
1. Configure your app into the App Settings panel for the right Platform (Android and/or iOS).
1. To use OneSignal on iOS devices, register the OneSignal-appId into  `tiapp.xml`:

    ```xml
    <property name="OneSignal_AppID" type="string">[App-id]</property>
    ```
1. To use OneSignal on Android devices, register some meta-data as well:

    ```xml
    <meta-data android:name="onesignal_app_id"
                   android:value="[App-id]" />
    ```
1. To use rich notifications on iOS 10 you need to add an extension to your app.
   To do so see:
   - [https://documentation.onesignal.com/docs/ios-sdk-setup#section-1-add-notification-service-extension](https://documentation.onesignal.com/docs/ios-sdk-setup#section-1-add-notification-service-extension)
   - [http://docs.appcelerator.com/platform/latest/#!/guide/Creating_iOS_Extensions_-_Siri_Intents](http://docs.appcelerator.com/platform/latest/#!/guide/Creating_iOS_Extensions_-_Siri_Intents)

#### Android

If you have some build errors about Google Play service dependencies you will need to add `googleServices {disableVersionCheck = true}` to your build.gradle file.

### Usage
1. Register device for Push Notifications

   ```js
       // This registers your device automatically into OneSignal
       var onesignal = require('com.williamrijksen.onesignal');
   ```
1. On iOS you'll need to request permission to use notifications:
   ```js
       onesignal.promptForPushNotificationsWithUserResponse(function(obj) {
           alert(JSON.stringify(obj));
       });
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
1. Set External User ID:

    ```js
        onesignal.setExternalUserId('your_db_user_id');
    ```
1. Remove External User ID:

    ```js
        onesignal.removeExternalUserId();
    ```
1. Get if user is subscribed (Boolean):

    ```js
        var subscribed = onesignal.retrieveSubscribed();
    ```
1. Get One Signal Player ID (String):

    ```js
        var res = onesignal.retrievePlayerId();
    ```
1. Get One Signal Token (String):

    ```js
        var token = onesignal.retrieveToken();
    ```
1. Get Permission Subscription State (iOS-only for now):

    ```js
        var res = onesignal.getPermissionSubscriptionState();
        /* res example:
            {
                "subscriptionStatus": {
                    "userSubscriptionSetting": true,
                    "subscribed": false,
                    "userId": "123-123-123-123-123456789",
                    "pushToken": null
                },
                "permissionStatus": {
                    "status": 2,
                    "provisional": false,
                    "hasPrompted": true
                },
                "emailSubscriptionStatus": {
                    "emailAddress": null,
                    "emailUserId": null
                }
            }
        */
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
1. Opened listener:   
   The returned content is matching the available payload on OneSignal:
   - [iOS](https://documentation.onesignal.com/docs/ios-native-sdk#section--osnotificationpayload-)
   - [Android](https://documentation.onesignal.com/docs/android-native-sdk#section--osnotificationpayload-)

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

1. Received listener:
    The returned content is matching the available payload on OneSignal:
   - [iOS](https://documentation.onesignal.com/docs/ios-native-sdk#section--osnotificationpayload-)
   - [Android](https://documentation.onesignal.com/docs/android-native-sdk#section--osnotificationpayload-)

   ```js
   onesignal.addEventListener('notificationReceived', function(evt) {
       console.log(' ***** Received! ' + JSON.stringify(evt));
   });
   ```

Cheers!

## Build yourself

### iOS

If you already have Titanium installed, skip the first 2 steps, if not let's install Titanium locally.

1. `brew install yarn --without-node` to install yarn without relying on a specific Node version
1. In the root directory execute `yarn install`
1. Step into the `ios` directory
1. If you want to update the OneSignal SDK:
  - Run `carthage update`
  - Drag and drop the `OneSignal.framework` from `Carthage/Build/iOS` to `platform`
1. Alter the `titanium.xcconfig` to build with the preferred SDK
1. To build the module execute `rm -rf build && ../node_modules/.bin/ti build -p ios --build-only`

### Android

1. `brew install yarn --without-node` to install yarn without relying on a specific Node version
1. In the root directory execute `yarn install`
1. Step into the android directory
1. Copy `build.properties.dist` to `build.properties` and edit to match your environment
1. To build the module execute `rm -rf build && mkdir -p build/docs && ../node_modules/.bin/ti build -p android --build-only`

#### Google Play Services

Since Titanium 7.x this module relies on [https://github.com/appcelerator-modules/ti.playservices](ti.playservices)

If you still need to support Titanium 6.x and you need to change the used Google Play Services version, execute the following actions:
1. Install the Google Play Services on your system:

   ```bash
   sdkmanager "extras;google;m2repository"
   ```
1. Fetch the 4 needed *.aar files from the SDK path `extras/google/m2repository/com/google/android/gms`
   - base
   - basement
   - gcm
   - idd
   - location

   For the version you want use.
1. Extract the *.aar file, and rename the `classes.jar` to `google-play-services-<part>.jar`.
1. Update the used jars in the `lib` folder.
1. Update the res folder with the one from the `google-play-services-basement.jar`
