//
//  OneSignalManager.h
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 01-08-17.
//
//

#import <Foundation/Foundation.h>
#import <OneSignal/OneSignal.h>
#import "OneSignalDelegate.h"

@interface OneSignalManager : NSObject {}

@property(assign, nonatomic) id<OneSignalDelegate> delegate;

- (OneSignalManager*)initWithNSNotification:(NSNotification*)notification;

@end
