/**
 * com.williamrijksen.onesignal
 *
 * Created by William Rijksen
 * Copyright (c) 2016 Enrise. All rights reserved.
 */

#import "TiModule.h"
#if __has_include(<OneSignal/OneSignal.h>)
#import <OneSignal/OneSignal.h>
#else
#import "OneSignal.h"
#endif
#import "OneSignalManager.h"

@interface ComWilliamrijksenOnesignalModule : TiModule<OneSignalDelegate> {}

typedef void(^TagsResultHandler)(NSDictionary*, NSError*);

- (void)promptForPushNotificationsWithUserResponse:(id)args;
- (void)sendTag:(id)args;
- (void)setSubscription:(id)args;
- (void)deleteTag:(id)args;
- (void)getTags:(id)value;
- (void)setLogLevel:(id)args;
- (void)idsAvailable:(id)args;
- (void)postNotification:(id)arguments;

@end
