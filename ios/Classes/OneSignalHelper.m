//
//  OneSignalHelper.m
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 27-03-18.
//

#import "OneSignalHelper.h"
#import <objc/runtime.h>

@implementation OneSignalHelper

+ (NSDictionary *)toDictionary: (OSNotificationPayload *)payload
{
    return @{@"notificationID": payload.notificationID,
             @"templateID": payload.templateID,
             @"templateName": payload.templateName,
             @"contentAvailable": @(payload.contentAvailable),
             @"mutableContent": @(payload.mutableContent),
             @"category": payload.category,
             @"badge": @(payload.badge),
             @"sound": payload.sound,
             @"title": payload.title,
             @"subtitle": payload.subtitle,
             @"body": payload.body,
             @"launchURL": payload.launchURL
    };
}

@end
//
///* Additional key value properties set within the payload */
//@property(readonly)NSDictionary* additionalData;
//
///* iOS 10+ : Attachments sent as part of the rich notification */
//@property(readonly)NSDictionary* attachments;
//
///* Action buttons passed */
//@property(readonly)NSArray *actionButtons;
//
///* Holds the original payload received
// Keep the raw value for users that would like to root the push */
//@property(readonly)NSDictionary *rawPayload;

