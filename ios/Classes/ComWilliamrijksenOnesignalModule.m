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

NSString * const TiNotificationReceived = @"notificationReceived";
NSString * const TiNotificationOpened = @"notificationOpened";

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

static NSMutableDictionary*_queuedBootEvents = nil;

#pragma mark Lifecycle

static ComWilliamrijksenOnesignalModule* _instance = nil;
+ (ComWilliamrijksenOnesignalModule*) instance
{
    return _instance;
}

+ (void) receivedHandler:(OSNotification *)notification {
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
    [self tryToPostNotification:notificationData withNotificationName:TiNotificationReceived];
}

+ (void) actionHandler:(OSNotificationOpenedResult *)result {
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
    [self tryToPostNotification:notificationData withNotificationName:TiNotificationOpened];
}

- (void)startup
{
    [super startup];
    NSLog(@"[INFO] started %@", self);
    if (_instance == nil) {
        _instance = self;
    }

    // cleanup old boot events
    [self performSelector:@selector(releaseQueuedBootEvents) withObject:self afterDelay:5.0];
}

-(void)shutdown:(id)sender
{
    [self releaseQueuedBootEvents];
    _instance = nil;

    [super shutdown:sender];
}

-(void)releaseQueuedBootEvents
{
    if (_queuedBootEvents != nil) {
        [_queuedBootEvents removeAllObjects];
        [_queuedBootEvents release];
        _queuedBootEvents = nil;
    }
}

+(void)onAppCreate:(NSNotification *)notification
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal onAppCreate");
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

+ (void)load
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal load");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppCreate:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

- (void)handleQueuedBootEvent:(NSString*)eventName
{
    if (_queuedBootEvents != nil && [_queuedBootEvents objectForKey:eventName] != nil) {
        NSLog(@"[DEBUG] com.williamrijksen.onesignal Fire event from startup %@", eventName);
        [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:[_queuedBootEvents objectForKey:eventName]];
        [_queuedBootEvents removeObjectForKey:eventName];
    }
}

-(void)_listenerAdded:(NSString*)type count:(int)count
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal add listener %@", type);
    if (count == 1 && [type isEqual:TiNotificationOpened]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationOpened:) name:TiNotificationOpened object:nil];
        [self handleQueuedBootEvent:type];
    }
    if (count == 1 && [type isEqual:TiNotificationReceived]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:TiNotificationReceived object:nil];
        [self handleQueuedBootEvent:type];
    }
}

-(void)_listenerRemoved:(NSString*)type count:(int)count
{
    NSLog(@"[DEBUG] com.williamrijksen.onesignal remove listener");
    if (count == 0 && [type isEqual:TiNotificationOpened]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TiNotificationOpened object:nil];
    }
    if (count == 0 && [type isEqual:TiNotificationReceived]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TiNotificationReceived object:nil];
    }
}

-(void)notificationOpened:(NSNotification*)info
{
    if (_instance != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary: @{
                                                                                        @"title" : [[info userInfo] valueForKey:@"title"],
                                                                                        @"body" : [[info userInfo] valueForKey:@"body"],
                                                                                        }];
            NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE notificationOpened: %@" , event);
            [self fireEvent:TiNotificationOpened withObject:event];
            RELEASE_TO_NIL(event);
        });
    }
}

-(void)notificationReceived:(NSNotification*)info
{
    if (_instance != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary: @{
                                                                                        @"title" : [[info userInfo] valueForKey:@"title"],
                                                                                        @"body" : [[info userInfo] valueForKey:@"body"],
                                                                                        }];
            NSLog(@"[DEBUG] com.williamrijksen.onesignal FIRE notificationReceived: %@" , event);
            [self fireEvent:TiNotificationReceived withObject:event];
            RELEASE_TO_NIL(event);
        });
    }
}

#pragma mark Public API's

- (void)promptForPushNotificationsWithUserResponse:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        NSLog(@"[DEBUG] com.williamrijksen.onesignal User accepted notifications: %d", accepted);
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

#pragma mark Helper Methods


+ (void)tryToPostNotification:(NSDictionary *)_notification withNotificationName:(NSString *)_notificationName
{
    if (_instance != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:_instance userInfo:_notification];
        return;
    }
    
    if (_queuedBootEvents == nil) {
        _queuedBootEvents = [[NSMutableDictionary alloc] init];
    }
    [_queuedBootEvents setObject:_notification forKey:_notificationName];
}

MAKE_SYSTEM_PROP(LOG_LEVEL_NONE, ONE_S_LL_NONE);
MAKE_SYSTEM_PROP(LOG_LEVEL_DEBUG, ONE_S_LL_DEBUG);
MAKE_SYSTEM_PROP(LOG_LEVEL_INFO, ONE_S_LL_INFO);
MAKE_SYSTEM_PROP(LOG_LEVEL_WARN, ONE_S_LL_WARN);
MAKE_SYSTEM_PROP(LOG_LEVEL_ERROR, ONE_S_LL_ERROR);
MAKE_SYSTEM_PROP(LOG_LEVEL_FATAL, ONE_S_LL_FATAL);
MAKE_SYSTEM_PROP(LOG_LEVEL_VERBOSE, ONE_S_LL_VERBOSE);

@end
