//
//  OneSignalPayload.m
//  com.williamrijksen.onesignal
//
//  Created by Jeroen van Dijk on 08/08/2017.
//
//

#import "OneSignalPayload.h"
#import <objc/runtime.h>

@implementation OneSignalPayload
@synthesize actionButtons = _actionButtons, additionalData = _additionalData, badge = _badge, body = _body, contentAvailable = _contentAvailable, notificationID = _notificationID, launchURL = _launchURL, rawPayload = _rawPayload, sound = _sound, subtitle = _subtitle, title = _title, attachments = _attachments;

/**
 * This method is a direct copy of https://github.com/OneSignal/OneSignal-iOS-SDK/blob/master/iOS_SDK/OneSignalSDK/Source/OneSignalHelper.m#L150
 *
 */
- (id)initWithRawMessage:(NSDictionary*)message {
    self = [super init];
    if (self && message) {
        _rawPayload = [NSDictionary dictionaryWithDictionary:message];

        BOOL is2dot4Format = [_rawPayload[@"os_data"][@"buttons"] isKindOfClass:[NSArray class]];

        if (_rawPayload[@"aps"][@"content-available"])
            _contentAvailable = (BOOL)_rawPayload[@"aps"][@"content-available"];
        else
            _contentAvailable = NO;

        if (_rawPayload[@"aps"][@"badge"])
            _badge = [_rawPayload[@"aps"][@"badge"] intValue];
        else
            _badge = [_rawPayload[@"badge"] intValue];

        _actionButtons = _rawPayload[@"o"];
        if (!_actionButtons) {
            if (is2dot4Format)
                _actionButtons = _rawPayload[@"os_data"][@"buttons"];
            else
                _actionButtons = _rawPayload[@"os_data"][@"buttons"][@"o"];
        }

        if(_rawPayload[@"aps"][@"sound"])
            _sound = _rawPayload[@"aps"][@"sound"];
        else if(_rawPayload[@"s"])
            _sound = _rawPayload[@"s"];
        else if (!is2dot4Format)
            _sound = _rawPayload[@"os_data"][@"buttons"][@"s"];

        if(_rawPayload[@"custom"]) {
            NSDictionary* custom = _rawPayload[@"custom"];
            if (custom[@"a"])
                _additionalData = [custom[@"a"] copy];
            _notificationID = custom[@"i"];
            _launchURL = custom[@"u"];

            _attachments = [_rawPayload[@"at"] copy];
        }
        else if(_rawPayload[@"os_data"]) {
            NSDictionary * os_data = _rawPayload[@"os_data"];

            NSMutableDictionary *additional = [_rawPayload mutableCopy];
            [additional removeObjectForKey:@"aps"];
            [additional removeObjectForKey:@"os_data"];
            _additionalData = [[NSDictionary alloc] initWithDictionary:additional];

            _notificationID = os_data[@"i"];
            _launchURL = os_data[@"u"];

            if (is2dot4Format) {
                if (os_data[@"att"])
                    _attachments = [os_data[@"att"] copy];
            }
            else {
                if (os_data[@"buttons"][@"at"])
                    _attachments = [os_data[@"buttons"][@"at"] copy];
            }
        }

        if(_rawPayload[@"m"]) {
            id m = _rawPayload[@"m"];
            if ([m isKindOfClass:[NSDictionary class]]) {
                _body = m[@"body"];
                _title = m[@"title"];
                _subtitle = m[@"subtitle"];
            }
            else
                _body = m;
        }
        else if(_rawPayload[@"aps"][@"alert"]) {
            id a = message[@"aps"][@"alert"];
            if ([a isKindOfClass:[NSDictionary class]]) {
                _body = a[@"body"];
                _title = a[@"title"];
                _subtitle = a[@"subtitle"];
            }
            else
                _body = a;
        }
        else if(_rawPayload[@"os_data"][@"buttons"][@"m"]) {
            id m = _rawPayload[@"os_data"][@"buttons"][@"m"];
            if ([m isKindOfClass:[NSDictionary class]]) {
                _body = m[@"body"];
                _title = m[@"title"];
                _subtitle = m[@"subtitle"];
            }
            else
                _body = m;
        }
    }

    return self;
}

- (NSDictionary *)toDictionary
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
