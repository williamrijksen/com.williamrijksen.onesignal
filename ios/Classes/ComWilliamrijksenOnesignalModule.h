/**
 * com.williamrijksen.onesignal
 *
 * Created by William Rijksen
 * Copyright (c) 2016 Enrise. All rights reserved.
 */

#import "TiModule.h"
#import <OneSignal/OneSignal.h>

@interface ComWilliamrijksenOnesignalModule : TiModule {}

typedef void(^TagsResultHandler)(NSDictionary*, NSError*);

- (void)promptForPushNotificationsWithUserResponse:(id)args;
- (void)sendTag:(id)args;
- (void)setSubscription:(id)args;
- (void)deleteTag:(id)args;
- (void)getTags:(id)value;
- (void)setLogLevel:(id)args;
- (void)postNotification:(id)arguments;

@end
