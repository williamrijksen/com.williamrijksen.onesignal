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
- (bool)retrieveSubscribed:(id)args;
- (NSString *)retrievePlayerId:(id)args;
- (NSString *)retrieveToken:(id)args;
- (void)setSubscription:(id)args;
- (void)setExternalUserId:(id)args;
- (void)removeExternalUserId:(id)args;
- (void)sendTag:(id)args;
- (void)deleteTag:(id)args;
- (void)getTags:(id)value;
- (NSDictionary *)getDeviceState:(id)args;
- (void)setLogLevel:(id)args;
- (void)postNotification:(id)arguments;

@end
