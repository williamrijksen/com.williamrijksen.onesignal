/**
 * com.williamrijksen.onesignal
 *
 * Created by William Rijksen
 * Copyright (c) 2016 Enrise. All rights reserved.
 */

#import "ComWilliamrijksenOnesignalModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation ComWilliamrijksenOnesignalModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"67065763-fd5e-4069-a877-6c7fd328f877";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.williamrijksen.onesignal";
}

#pragma mark Lifecycle

- (void) receivedHandler:(OSNotification *)notification {
    if ([self _hasListeners:@"notificationReceived"]) {
        OSNotificationPayload* payload = notification.payload;

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
                                            @"additionalData": additionalData
                                        };
        [self fireEvent:@"notificationReceived" withObject:notificationData];
    }
};
    
- (void) actionHandler:(OSNotificationOpenedResult *)result {
    if ([self _hasListeners:@"notificationOpened"]) {
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
        [self fireEvent:@"notificationOpened" withObject:notificationData];
    }
}

- (void)startup
{
   [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        NSLog(@"User accepted notifications: %d", accepted);
   }];
}

+(void)onAppCreate:(NSNotification *)notification
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal onAppCreate");
    NSDictionary *userInfo = [notification userInfo];
    NSDictionary *launchOptions = [userInfo valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    NSString *OneSignalAppID = [[TiApp tiAppProperties] objectForKey:@"OneSignal_AppID"];
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:OneSignalAppID
            handleNotificationAction:^(OSNotificationOpenedResult *result) {
                NSLog(@"User opened notification");
                                    }
                            settings:@{kOSSettingsKeyAutoPrompt: @false}
    ];
}

+ (void)load
{
    NSLog(@"Starting com.williamrijksen.onesignal");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppCreate:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

#pragma mark Public API's

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

- (void)idsAvailable:(id)args
{
	id value = args;
    ENSURE_UI_THREAD(idsAvailable, value);
    ENSURE_SINGLE_ARG(value, KrollCallback);

	[OneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
		NSMutableDictionary *idsDict = [NSMutableDictionary dictionaryWithDictionary:@{
			@"userId" : userId ?: @[],
         	@"pushToken" :pushToken ?: @[]
     	}];
		NSArray *invocationArray = [[NSArray alloc] initWithObjects:&idsDict count:1];
        [value call:invocationArray thisObject:self];
        [invocationArray release];
	}];
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
