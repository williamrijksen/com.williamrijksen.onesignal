//
//  OneSignalModuleHelper.h
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 27-03-18.
//

#import <Foundation/Foundation.h>
#if __has_include(<OneSignal/OneSignal.h>)
#import <OneSignal/OneSignal.h>
#else
#import "OneSignal.h"
#endif

@interface OneSignalModuleHelper : NSObject

+ (NSDictionary *)toDictionary: (OSNotificationPayload *)payload;

@end
