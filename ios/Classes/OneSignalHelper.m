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
    unsigned int count = 0;

    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    objc_property_t *properties = class_copyPropertyList([self class], &count);

    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self valueForKey:key];

        if (value == nil) {
            // nothing todo
        }
        else if ([value isKindOfClass:[NSNumber class]]
                 || [value isKindOfClass:[NSString class]]
                 || [value isKindOfClass:[NSDictionary class]]) {
            // TODO: extend to other types
            [dictionary setObject:value forKey:key];
        }
        else if ([value isKindOfClass:[NSObject class]]) {
            [dictionary setObject:[value toDictionary] forKey:key];
        }
        else {
            NSLog(@"Invalid type for %@ (%@)", NSStringFromClass([self class]), key);
        }
    }

    free(properties);

    return dictionary;
}

@end
