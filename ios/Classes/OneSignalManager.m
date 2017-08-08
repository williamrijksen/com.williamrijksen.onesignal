//
//  OneSignalManager.m
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 01-08-17.
//
//

#import "OneSignalManager.h"
#import "TiApp.h"

@implementation OneSignalManager {}

- (void) receivedHandler:(NSDictionary *)rawPayload {
    NSLog(@"[DEBUG] com.williamrijksen.onesignal Result notification data %@", rawPayload);

    [self.delegate notificationReceived:rawPayload];
}

- (void) actionHandler:(NSDictionary *)rawPayload {
    NSLog(@"[DEBUG] com.williamrijksen.onesignal Open notification data %@", rawPayload);

    [self.delegate notificationOpened:rawPayload];
}

- (OneSignalManager*)initWithNSNotification:(NSNotification *)notification
{
    self = [super init];
    if (self) {
        NSLog(@"[DEBUG] com.williamrijksen.onesignal initWithLaunchOptions");

        id notificationReceiverBlock = ^(OSNotification *notification) {
            [self receivedHandler:notification.payload.rawPayload];
        };

        id notificationOpenedBlock = ^(OSNotificationOpenedResult *result) {
            [self actionHandler:result.notification.payload.rawPayload];
        };

        id onesignalInitSettings = @{kOSSettingsKeyAutoPrompt : @NO};

        NSDictionary *userInfo = [notification userInfo];
        NSDictionary *launchOptions =
            [userInfo valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        NSString *OneSignalAppID = [[TiApp tiAppProperties] objectForKey:@"OneSignal_AppID"];
        [OneSignal initWithLaunchOptions:launchOptions
                                   appId:OneSignalAppID
              handleNotificationReceived:notificationReceiverBlock
                handleNotificationAction:notificationOpenedBlock
                                settings:onesignalInitSettings];
    }
    return self;
}

@end
