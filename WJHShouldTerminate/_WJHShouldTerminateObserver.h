//
//  _WJHShouldTerminateObserver.h
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WJHShouldTerminate;

/**
 This class is a private implementation detail.

 It is returned to client code, but only as an opaque type.
 */
@interface _WJHShouldTerminateObserver : NSObject

/**
 Initialize with a block that acts as an observer for WJHShouldTerminateNotification on the default notification center.

 @param block the block that is called whenever a WJHShouldTerminateNotification is received.  The argument to the block call will be notification.object.

 @note When the returned object deallocs, the observer will be automatically removed from the notification center.
 */
- (instancetype)initWithBlock:(void (^)(WJHShouldTerminate *))block;

@end
