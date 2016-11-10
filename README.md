# Titanium OneSignal



### com.williamrijksen.onesignal

This module gives you the possibility to integrate OneSignal into you're Appcelerator Android or iOS-application. It's even possible to target people by registering tags.

### Setup

1. Integrate the module into the `modules` folder and define them into the `tiapp.xml` file:
    
    ```xml
    <modules>
      <module platform="iphone" version="1.1.0">com.williamrijksen.onesignal</module>
      <module platform="android" version="1.0.0">com.williamrijksen.onesignal</module>
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
1. Get tags (iOS-only for now):

    ```js
        onesignal.getTags(function(e) {
            if (!e.success) {
                Ti.API.error("Error: " + e.error);
                return
            }

            Ti.API.info(e.results);
        });
    ```   
1. Set log level (iOS-only for now):

    ```js
        onesignal.setLogLevel({
            logLevel: onesignal.LOG_LEVEL_DEBUG,
            visualLevel: onesignal.LOG_LEVEL_NONE
        });
    ```   
Cheers!
