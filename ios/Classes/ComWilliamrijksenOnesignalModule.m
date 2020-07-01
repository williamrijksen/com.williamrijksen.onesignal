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
        OSNotificationPayload* payload = notification.payload;
        NSLog(@"[DEBUG] com.williamrijksen.onesignal notification received %@", payload);
        [self fireEvent:NotificationReceived withObject:[OneSignalModuleHelper toDictionary:payload]];
    };

    id notificationOpenedBlock = ^(OSNotificationOpenedResult *result) {
        OSNotificationPayload* payload = result.notification.payload;
        NSLog(@"[DEBUG] com.williamrijksen.onesignal notification opened %@", payload);
        [self fireEvent:NotificationOpened withObject:[OneSignalModuleHelper toDictionary:payload]];
    };

    id onesignalInitSettings = @{
        kOSSettingsKeyAutoPrompt : @false
    };

    NSString *OneSignalAppID = [[TiApp tiAppProperties] objectForKey:@"OneSignal_AppID"];
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:OneSignalAppID
          handleNotificationReceived:notificationReceivedBlock
            handleNotificationAction:notificationOpenedBlock
                            settings:onesignalInitSettings];
    [OneSignal setLocationShared:YES];
    OneSignal.inFocusDisplayType = OSNotificationDisplayTypeNone;
    return YES;
}

#pragma mark - Listernes

- (void)_listenerAdded:(NSString*)type count:(int)count
{
    if (count == 1 && [type isEqual:NotificationOpened]) {
        NSDictionary *initialNotificationPayload = [TiApp.app.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        OSNotificationPayload *oneSignalPayload = [OSNotificationPayload parseWithApns:initialNotificationPayload];
        NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE cold boot NotificationOpened");
        [self fireEvent:NotificationOpened withObject:[OneSignalModuleHelper toDictionary:oneSignalPayload]];
    }
}

#pragma mark Public API's

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
    [OneSignal setSubscription:[TiUtils boolValue:args]];
}

- (void)setExternalUserId:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSString);
    
    [OneSignal setExternalUserId:[TiUtils stringValue:args] withCompletion:^(NSDictionary *results) {
        NSLog(@"Set external user id update complete with results: %@", results.description);
    }];
}

- (void)removeExternalUserId:(id)arguments
{
    id args = arguments;
    ENSURE_UI_THREAD_1_ARG(args); // not necessary but app was crashing without it
    [OneSignal removeExternalUserId:^(NSDictionary *results) {
        NSLog(@"Remove external user id  complete with results: %@", results.description);
    }];
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

- (NSDictionary *)getPermissionSubscriptionState:(id)args
{
    // Maybe it should use OSDevice class instead in the future
	id value = args;
    ENSURE_UI_THREAD(getPermissionSubscriptionState, value);

    OSPermissionSubscriptionState* state = [OneSignal getPermissionSubscriptionState];
    return [state toDictionary];
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

MAKE_SYSTEM_PROP(LOG_LEVEL_NONE, ONE_S_LL_NONE);
MAKE_SYSTEM_PROP(LOG_LEVEL_DEBUG, ONE_S_LL_DEBUG);
MAKE_SYSTEM_PROP(LOG_LEVEL_INFO, ONE_S_LL_INFO);
MAKE_SYSTEM_PROP(LOG_LEVEL_WARN, ONE_S_LL_WARN);
MAKE_SYSTEM_PROP(LOG_LEVEL_ERROR, ONE_S_LL_ERROR);
MAKE_SYSTEM_PROP(LOG_LEVEL_FATAL, ONE_S_LL_FATAL);
MAKE_SYSTEM_PROP(LOG_LEVEL_VERBOSE, ONE_S_LL_VERBOSE);

@end
