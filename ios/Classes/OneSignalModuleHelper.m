//
//  OneSignalModuleHelper.m
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 27-03-18.
//

#import "OneSignalModuleHelper.h"

@implementation OneSignalModuleHelper

+ (NSDictionary *)toDictionary: (OSNotificationPayload *)payload
{
    return @{@"notificationID": payload.notificationID ?: [NSNull null],
             @"templateID": payload.templateID ?: [NSNull null],
             @"templateName": payload.templateName ?: [NSNull null],
             @"contentAvailable": @(payload.contentAvailable),
             @"mutableContent": @(payload.mutableContent),
             @"category": payload.category ?: [NSNull null],
             @"badge": @(payload.badge),
             @"badgeIncrement": @(payload.badgeIncrement),
             @"sound": payload.sound ?: [NSNull null],
             @"title": payload.title ?: [NSNull null],
             @"subtitle": payload.subtitle ?: [NSNull null],
             @"body": payload.body ?: [NSNull null],
             @"launchURL": payload.launchURL ?: [NSNull null],
             @"additionalData": payload.additionalData ?: [NSNull null],
             @"attachments": payload.attachments ?: [NSNull null],
             @"actionButtons": payload.actionButtons ?: [NSNull null],
             @"rawPayload": payload.rawPayload ?: [NSNull null]
    };
}

@end