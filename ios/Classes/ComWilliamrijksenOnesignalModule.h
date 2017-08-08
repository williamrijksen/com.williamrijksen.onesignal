/**
 * com.williamrijksen.onesignal
 *
 * Created by William Rijksen
 * Copyright (c) 2016 Enrise. All rights reserved.
 */

#import "TiModule.h"
#import <OneSignal/OneSignal.h>
#import "OneSignalManager.h"

@interface ComWilliamrijksenOnesignalModule : TiModule<OneSignalDelegate> {}

typedef void(^TagsResultHandler)(NSDictionary*, NSError*);

- (void)promptForPushNotificationsWithUserResponse:(id)args;
- (void)sendTag:(id)args;
- (void)deleteTag:(id)args;
- (void)getTags:(id)value;
- (void)setLogLevel:(id)args;
- (void)idsAvailable:(id)args;
- (void)postNotification:(id)arguments;

@end
