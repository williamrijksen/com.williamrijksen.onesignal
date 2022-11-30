/**
 * com.williamrijksen.onesignal
 *
 * Created by William Rijksen
 * Copyright (c) 2016 Enrise. All rights reserved.
 */

#import "ComWilliamrijksenOnesignalModule.h"
#import "OneSignalModuleHelper.h"
#import <OneSignal/OneSignal.h>
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation ComWilliamrijksenOnesignalModule

NSString * const NotificationReceived = @"notificationReceived";
NSString * const NotificationOpened = @"notificationOpened";

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID
{
	return @"67065763-fd5e-4069-a877-6c7fd328f877";
}

// this is generated for your module, please do not change it
- (NSString*)moduleId
{
	return @"com.williamrijksen.onesignal";
}

#pragma mark Lifecycle

- (void)_configure
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal configure");
    [super _configure];
    [[TiApp app] registerApplicationDelegate:self];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal didFinishLaunchingWithOptions");

    id notificationReceivedBlock = ^(OSNotification *notification) {
        NSLog(@"[DEBUG] com.williamrijksen.onesignal notification received %@", notification);
        [self fireEvent:NotificationReceived withObject:[OneSignalModuleHelper toDictionary:notification]];
    };

    id notificationOpenedBlock = ^(OSNotificationOpenedResult *result) {
        OSNotification* payload = result.notification;
        NSLog(@"[DEBUG] com.williamrijksen.onesignal notification opened %@", payload);
        [self fireEvent:NotificationOpened withObject:[OneSignalModuleHelper toDictionary:payload]];
    };

    id onesignalInitSettings = @{
        //kOSSettingsKeyAutoPrompt : @false
    };

    NSString *OneSignalAppID = [[TiApp tiAppProperties] objectForKey:@"OneSignal_AppID"];
    
    
    [OneSignal initWithLaunchOptions:launchOptions];
    [OneSignal setAppId:OneSignalAppID];

    
    [OneSignal setLocationShared:YES];
    return YES;
}

#pragma mark - Listernes

- (void)_listenerAdded:(NSString*)type count:(int)count
{
    if (count == 1 && [type isEqual:NotificationOpened]) {
        NSDictionary *initialNotificationPayload = [TiApp.app.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        OSNotification *oneSignalPayload = [OSNotification parseWithApns:initialNotificationPayload];
        NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE cold boot NotificationOpened");
        [self fireEvent:NotificationOpened withObject:[OneSignalModuleHelper toDictionary:oneSignalPayload]];
    }
}

#pragma mark Public API's

- (bool)retrieveSubscribed:(id)args
{
    return [OneSignal getDeviceState].isSubscribed;
}

- (NSString *)retrievePlayerId:(id)args
{
    return [OneSignal getDeviceState].userId;
}

- (NSString *)retrieveToken:(id)args
{
    return [OneSignal getDeviceState].pushToken;
}

- (void)promptForPushNotificationsWithUserResponse:(id)args
{
    ENSURE_UI_THREAD(promptForPushNotificationsWithUserResponse, args);
    ENSURE_SINGLE_ARG(args, KrollCallback);

    if([args isKindOfClass:[KrollCallback class]]) {
        [self replaceValue:args forKey:@"callback" notification:NO];
    }

    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        NSLog(@"[DEBUG] com.williamrijksen.onesignal User accepted notifications: %d", accepted);
        if ([args isKindOfClass:[KrollCallback class]]) {
            NSDictionary* event = @{
                @"accepted": NUMBOOL(accepted)
            };
            [self fireCallback:@"callback" withArg:event withSource:self];
        }
    }];
}

- (void)setSubscription:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSNumber);
    [OneSignal disablePush:[TiUtils boolValue:args]];
}

- (void)setExternalUserId:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSString);
    
    [OneSignal setExternalUserId:[TiUtils stringValue:args] withSuccess:^(NSDictionary *results) {
        NSLog(@"Set external user id update complete with results: %@", results.description);
    }  withFailure:^(NSError *error) {
        
    }];
}

- (void)removeExternalUserId:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args); // not necessary but app was crashing without it
    [OneSignal removeExternalUserId];
}

- (void)sendTag:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSString *key = [TiUtils stringValue:[args objectForKey:@"key"]];
    NSString *value = [TiUtils stringValue:[args objectForKey:@"value"]];
    [OneSignal sendTag:key value:value];
}

- (void)deleteTag:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSString *key = [TiUtils stringValue:[args objectForKey:@"key"]];
    [OneSignal deleteTag:key];
}

- (void)getTags:(id)args
{
    id value = args;
    ENSURE_UI_THREAD(getTags, value);
    ENSURE_SINGLE_ARG(value, KrollCallback);

    // Unifies the results (success) and error blocks to fire a single callback
    TagsResultHandler resultsBlock = ^(NSDictionary *results, NSError* error) {
        NSMutableDictionary *propertiesDict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"success": NUMBOOL(error == nil),
        }];

		if (error == nil) {
			// Are all keys and values Kroll-save? If not, we need a validation utility
            propertiesDict[@"results"] = results ?: @[];
        } else {
			propertiesDict[@"error"] = [error localizedDescription];
            propertiesDict[@"code"] = NUMINTEGER([error code]);
        }

        NSArray *invocationArray = [[NSArray alloc] initWithObjects:&propertiesDict count:1];
        [value call:invocationArray thisObject:self];
        [invocationArray release];
    };

    [OneSignal getTags:^(NSDictionary *results) {
        resultsBlock(results, nil);
    } onFailure:^(NSError *error) {
        resultsBlock(nil, error);
    }];
}

- (NSDictionary *)getDeviceState:(id)args
{
    // Maybe it should use OSDevice class instead in the future
	id value = args;
    ENSURE_UI_THREAD(getDeviceState, value);

    OSDeviceState* state = [OneSignal getDeviceState];
    return state.jsonRepresentation;
}

- (void)postNotification:(id)arguments
{
	id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

	NSString *message = [TiUtils stringValue:[args objectForKey:@"message"]];
	NSArray *playerIds = [args valueForKey:@"playerIds"];

	if(([message length] != 0) && ([playerIds count] != 0)){
		[OneSignal postNotification:@{
			@"contents" : @{@"en": message},
	   		@"include_player_ids": playerIds
		}];
	}
}

- (bool)isRooted
{
    return [self isJailbroken];
}

- (void)setLogLevel:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD(setLogLevel, args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    id logLevel = [args objectForKey:@"logLevel"];
    id visualLevel = [args objectForKey:@"visualLevel"];

    ENSURE_TYPE(logLevel, NSNumber);
    ENSURE_TYPE(visualLevel, NSNumber);

    [OneSignal setLogLevel:[TiUtils intValue:logLevel] visualLevel:[TiUtils intValue:visualLevel]];
}

- (BOOL)isJailbroken {
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    FILE *file = fopen("/Applications/Cydia.app", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r");
    if (file) {
        fclose(file);
        return YES;
    }

    file = fopen("/bin/bash", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/usr/sbin/sshd", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/etc/apt", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/usr/bin/ssh", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:@"/Applications/Cydia.app"])
        return YES;
    else if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"])
        return YES;
    else if ([fileManager fileExistsAtPath:@"/bin/bash"])
        return YES;
    else if ([fileManager fileExistsAtPath:@"/usr/sbin/sshd"])
        return YES;
    else if ([fileManager fileExistsAtPath:@"/etc/apt"])
        return YES;
    else if ([fileManager fileExistsAtPath:@"/usr/bin/ssh"])
        return YES;
    
    // Omit logic below since they show warnings in the device log on iOS 9 devices.
    if (NSFoundationVersionNumber > 1144.17) // NSFoundationVersionNumber_iOS_8_4
        return NO;
    
    // Check if the app can access outside of its sandbox
    NSError *error = nil;
    NSString *string = @".";
    [string writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error)
        return YES;
    else
        [fileManager removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    
    // Check if the app can open a Cydia's URL scheme
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])
        return YES;
    
#endif
    
    return NO;
}

MAKE_SYSTEM_PROP(LOG_LEVEL_NONE, ONE_S_LL_NONE);
MAKE_SYSTEM_PROP(LOG_LEVEL_DEBUG, ONE_S_LL_DEBUG);
MAKE_SYSTEM_PROP(LOG_LEVEL_INFO, ONE_S_LL_INFO);
MAKE_SYSTEM_PROP(LOG_LEVEL_WARN, ONE_S_LL_WARN);
MAKE_SYSTEM_PROP(LOG_LEVEL_ERROR, ONE_S_LL_ERROR);
MAKE_SYSTEM_PROP(LOG_LEVEL_FATAL, ONE_S_LL_FATAL);
MAKE_SYSTEM_PROP(LOG_LEVEL_VERBOSE, ONE_S_LL_VERBOSE);

@end
