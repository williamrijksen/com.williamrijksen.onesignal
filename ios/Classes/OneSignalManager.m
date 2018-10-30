//
//  OneSignalManager.m
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 01-08-17.
//
//

#import "OneSignalManager.h"
#import "OneSignalModuleHelper.h"
#import "TiApp.h"

@implementation OneSignalManager {}

- (void) receivedHandler:(OSNotificationPayload *)payload {
    NSLog(@"[DEBUG] com.williamrijksen.onesignal Result notification data %@", payload);

    [self.delegate notificationReceived:[OneSignalModuleHelper toDictionary:payload]];
}

- (void) actionHandler:(OSNotificationPayload *)payload {
    NSLog(@"[DEBUG] com.williamrijksen.onesignal Open notification data %@", payload);

    [self.delegate notificationOpened:[OneSignalModuleHelper toDictionary:payload]];
}

- (OneSignalManager*)initWithNSNotification:(NSNotification *)notification
{
    self = [super init];
    if (!self) {
        return nil;
    }

    NSLog(@"[DEBUG] com.williamrijksen.onesignal initWithLaunchOptions");

    id receiverBlock = ^(OSNotification *notification) {
        [self receivedHandler:notification.payload];
    };

    id openedBlock = ^(OSNotificationOpenedResult *result) {
        [self actionHandler:result.notification.payload];
    };

    id settings = @{
        kOSSettingsKeyAutoPrompt : @NO,
        kOSSettingsKeyInFocusDisplayOption : @(OSNotificationDisplayTypeNone)
    };

    NSDictionary *userInfo = [notification userInfo];
    NSDictionary *launchOptions = [userInfo valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    NSString *OneSignalAppID = [[TiApp tiAppProperties] objectForKey:@"OneSignal_AppID"];
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:OneSignalAppID
          handleNotificationReceived:receiverBlock
            handleNotificationAction:openedBlock
                            settings:settings];
    return self;
}

@end