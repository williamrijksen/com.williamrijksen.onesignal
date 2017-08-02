//
//  OneSignalManager.m
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 01-08-17.
//
//

#import "OneSignalManager.h"
#import <OneSignal/OneSignal.h>
#import "TiApp.h"

@implementation OneSignalManager {}

- (void) receivedHandler:(OSNotification *)notification {
    OSNotificationPayload* payload = notification.payload;
    
    NSString* title = @"";
    NSString* body = @"";
    NSDictionary* additionalData = [[NSDictionary alloc] init];
    
    if (payload.title) {
        title = payload.title;
    }
    
    if (payload.body) {
        body = [payload.body copy];
    }
    
    if (payload.additionalData) {
        additionalData = payload.additionalData;
    }
    
    NSDictionary* notificationData = @{
                                       @"title": title,
                                       @"body": body,
                                       @"additionalData": additionalData
                                       };
    [self.delegate notificationReceived:notificationData];
}

- (void) actionHandler:(OSNotificationOpenedResult *)result {
    OSNotificationPayload* payload = result.notification.payload;
    
    NSString* title = @"";
    NSString* body = @"";
    NSDictionary* additionalData = [[NSDictionary alloc] init];
    
    if(payload.title) {
        title = payload.title;
    }
    
    if (payload.body) {
        body = [payload.body copy];
    }
    
    if (payload.additionalData) {
        additionalData = payload.additionalData;
    }
    
    NSDictionary* notificationData = @{
                                       @"title": title,
                                       @"body": body,
                                       @"additionalData": additionalData};
    [self.delegate notificationReceived:notificationData];
}

- (OneSignalManager*)initWithNSNotification:(NSNotification*)notification
{
    self = [super init];
    if (self) {
        NSDictionary *userInfo = [notification userInfo];
        NSDictionary *launchOptions = [userInfo valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        NSString *OneSignalAppID = [[TiApp tiAppProperties] objectForKey:@"OneSignal_AppID"];
        [OneSignal initWithLaunchOptions:launchOptions
                                   appId:OneSignalAppID
              handleNotificationReceived:^(OSNotification *notification) {
                  NSLog(@"[DEBUG] com.williamrijksen.onesignal notification");
                  [self receivedHandler:notification];
              }
                handleNotificationAction:^(OSNotificationOpenedResult *result) {
                    NSLog(@"[DEBUG] com.williamrijksen.onesignal User opened notification");
                    [self actionHandler:result];
                }
                                settings:@{kOSSettingsKeyAutoPrompt: @false}
         ];
        
    }
    return self;
}

@end
