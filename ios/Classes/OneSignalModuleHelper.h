//
//  OneSignalModuleHelper.h
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 27-03-18.
//

#import <Foundation/Foundation.h>
#import <OneSignal/OneSignal.h>

@interface OneSignalModuleHelper : NSObject

+ (NSDictionary *)toDictionary: (OSNotificationPayload *)payload;

@end