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
      <module platform="iphone" version="2.0.1">com.williamrijksen.onesignal</module>
      <module platform="android" version="2.0.1">com.williamrijksen.onesignal</module>
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
    <meta-data android:name="onesignal_google_project_number"
                   android:value="str:[Google project id]" />
    ```
1. To use rich notifications on iOS 10 you need to add an extension to your app.
   To do so see:
   - [https://documentation.onesignal.com/docs/ios-sdk-setup#section-1-add-notification-service-extension](https://documentation.onesignal.com/docs/ios-sdk-setup#section-1-add-notification-service-extension)
   - [http://docs.appcelerator.com/platform/latest/#!/guide/Creating_iOS_Extensions_-_Siri_Intents](http://docs.appcelerator.com/platform/latest/#!/guide/Creating_iOS_Extensions_-_Siri_Intents)

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
1. IdsAvailable:

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
1. Set subscription:

    ```js
        // You can call this method with false to opt users out of receiving all notifications through OneSignal. You can pass true later to opt users back into notifications.
        onesignal.setSubscription(false);
    ```
1. Set log level:

    ```js
        onesignal.setLogLevel({
            logLevel: onesignal.LOG_LEVEL_DEBUG,
            visualLevel: onesignal.LOG_LEVEL_NONE
        });
    ```
1. clearOneSignalNotifications (android-only for now):

    ```js
        onesignal.clearOneSignalNotifications();
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
1. Step into the ios directory
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
