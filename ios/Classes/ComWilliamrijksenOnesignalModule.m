/**
 * com.williamrijksen.onesignal
 *
 * Created by William Rijksen
 * Copyright (c) 2016 Enrise. All rights reserved.
 */

#import "ComWilliamrijksenOnesignalModule.h"
#import "OneSignalPayload.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation ComWilliamrijksenOnesignalModule

NSString * const TiNotificationReceived = @"notificationReceived";
NSString * const TiNotificationOpened = @"notificationOpened";

static OneSignalManager* _oneSignalManager = nil;

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

- (void)startup
{
    [super startup];

    [_oneSignalManager setDelegate:self];
    NSLog(@"[INFO] started %@", self);
}

-(void)shutdown:(id)sender
{
    _oneSignalManager = nil;

    [super shutdown:sender];
}

+(void)initOneSignal:(NSNotification *)notification
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal init initOnesignal?");
    if (!_oneSignalManager) {
        _oneSignalManager = [[OneSignalManager alloc] initWithNSNotification:notification];
    }
}

+ (void)load
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal load");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initOneSignal:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

#pragma mark Listeners

- (void)_listenerAdded:(NSString*)type count:(int)count
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal add listener %@ count %i", type, count);

    if (count == 1) {
				if ([type isEqual:TiNotificationOpened]) {
					NSLog(@"Notification opened handler added");
					NSDictionary* userInfo = [[[TiApp app] launchOptions] objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	        if (userInfo) {
	            OneSignalPayload *payload = [[OneSignalPayload alloc] initWithRawMessage:userInfo];
	            NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE cold boot TiNotificationOpened");
	            [self fireEvent:TiNotificationOpened withObject:[payload toDictionary]];
	        }
		    } else if ([type isEqual:TiNotificationReceived]) {
						NSLog(@"Notification received handler added");
						NSDictionary* userInfo = [[[TiApp app] launchOptions] objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		        if (userInfo) {
		            OneSignalPayload *payload = [[OneSignalPayload alloc] initWithRawMessage:userInfo];
		            NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE TiNotificationReceived");
		            [self fireEvent:TiNotificationReceived withObject:[payload toDictionary]];
		        }
		    }
		}
}

-(void)notificationOpened:(NSDictionary*)info
{
    OneSignalPayload *payload = [[OneSignalPayload alloc] initWithRawMessage:info];

    if ([self _hasListeners:TiNotificationOpened]) {
        NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE TiNotificationOpened");
        [self fireEvent:TiNotificationOpened withObject:[payload toDictionary]];
    }
}

-(void)notificationReceived:(NSDictionary*)info
{
    OneSignalPayload *payload = [[OneSignalPayload alloc] initWithRawMessage:info];

		if ([self _hasListeners:TiNotificationReceived]) {
        NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE TiNotificationReceived");
        [self fireEvent:TiNotificationReceived withObject:[payload toDictionary]];
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
