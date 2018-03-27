//
//  OneSignalManager.h
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 01-08-17.
//
//

#import <Foundation/Foundation.h>
#if __has_include(<OneSignal/OneSignal.h>)
#import <OneSignal/OneSignal.h>
#else
#import "OneSignal.h"
#endif
#import "OneSignalDelegate.h"

@interface OneSignalManager : NSObject {}

@property(assign, nonatomic) id<OneSignalDelegate> delegate;

- (OneSignalManager*)initWithNSNotification:(NSNotification*)notification;

@end
