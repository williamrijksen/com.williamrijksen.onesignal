//
//  OneSignalDelegate.h
//  com.williamrijksen.onesignal
//
//  Created by William Rijksen on 01-08-17.
//
//

#import <Foundation/Foundation.h>

@protocol OneSignalDelegate <UIApplicationDelegate>

-(void)notificationReceived:(NSDictionary*)payload;
-(void)notificationOpened:(NSDictionary*)payload;

@end