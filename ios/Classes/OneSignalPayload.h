//
//  OneSignalPayload.h
//  com.williamrijksen.onesignal
//
//  Created by Jeroen van Dijk on 08/08/2017.
//
//

#import <Foundation/Foundation.h>

#ifndef OneSignalPayload_h
#define OneSignalPayload_h

/**
 * This structure is a direct copy of https://github.com/OneSignal/OneSignal-iOS-SDK/blob/master/iOS_SDK/OneSignalSDK/Source/OneSignal.h#L83
 *
 */

// #### Notification Payload Received Object

@interface OneSignalPayload : NSObject

/* Unique Message Identifier */
@property(readonly)NSString* notificationID;

/* Provide this key with a value of 1 to indicate that new content is available.
 Including this key and value means that when your app is launched in the background or resumed application:didReceiveRemoteNotification:fetchCompletionHandler: is called. */
@property(readonly)BOOL contentAvailable;

/* The badge assigned to the application icon */
@property(readonly)NSUInteger badge;

/* The sound parameter passed to the notification
 By default set to UILocalNotificationDefaultSoundName */
@property(readonly)NSString* sound;

/* Main push content */
@property(readonly)NSString* title;
@property(readonly)NSString* subtitle;
@property(readonly)NSString* body;

/* Web address to launch within the app via a UIWebView */
@property(readonly)NSString* launchURL;

/* Additional key value properties set within the payload */
@property(readonly)NSDictionary* additionalData;

/* iOS 10+ : Attachments sent as part of the rich notification */
@property(readonly)NSDictionary* attachments;

/* Action buttons passed */
@property(readonly)NSArray *actionButtons;

/* Holds the original payload received
 Keep the raw value for users that would like to root the push */
@property(readonly)NSDictionary *rawPayload;

- (id)initWithRawMessage:(NSDictionary*)message;
- (NSDictionary *)toDictionary;

@end

#endif /* OneSignalPayload_h */
