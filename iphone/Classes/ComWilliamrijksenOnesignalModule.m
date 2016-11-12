/**
 * com.williamrijksen.onesignal
 *
 * Created by Your Name
 * Copyright (c) 2016 Your Company. All rights reserved.
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

- (void)startup
{
    [super startup];
    [[TiApp app] setRemoteNotificationDelegate:self];

    NSString *OneSignalAppID = [[TiApp tiAppProperties] objectForKey:@"OneSignal_AppID"];
    [OneSignal initWithLaunchOptions:[[TiApp app] launchOptions] appId:OneSignalAppID];
}

#pragma mark Public API's

- (void)sendTag:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSString *key = [TiUtils stringValue:[args objectForKey:@"key"]];
    NSString *value = [TiUtils stringValue:[args objectForKey:@"value"]];
    [OneSignal sendTag:key value:value];
}

- (void)deleteTag:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSString *key = [TiUtils stringValue:[args objectForKey:@"key"]];
    [OneSignal deleteTag:key];
}

- (void)getTags:(id)value
{
    ENSURE_UI_THREAD(getTags, value);
    ENSURE_SINGLE_ARG(value, KrollCallback);
        
    // Unifies the results (success) and error blocks to fire a single callback
    TagsResultHandler resultsBlock = ^(NSDictionary *results, NSError* error) {
        NSMutableDictionary *propertiesDict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"success": NUMBOOL(error == nil),
        }];
        
        if (!error) {
            // Are all keys and values Kroll-save? If not, we need a validation utility
            [propertiesDict setObject:results ?: @[] forKey:@"results"];
        } else {
            [propertiesDict setObject:[error localizedDescription] forKey:@"error"];
            [propertiesDict setObject:NUMINTEGER([error code]) forKey:@"code"];
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

- (void)setLogLevel:(id)args
{
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
