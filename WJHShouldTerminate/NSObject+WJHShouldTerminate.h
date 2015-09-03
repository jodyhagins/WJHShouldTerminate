//
//  NSObject+WJHShouldTerminate.h
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WJHShouldTerminate;

@interface NSObject (WJHShouldTerminate)

/**
 Register a block that will be executed whenever a request to terminate the application is made.

 @param block the block that will be executed.  If nil, the currently registered block is unregistered.
 
 @note The block will remain registered for notifications until reset to nil, reset to another block, or the object deallocs.
 */
- (void)wjh_setShouldTerminateBlock:(void (^)(WJHShouldTerminate *))block;

/**
 Register a block that will be executed whenever a request to terminate the application is made.

 @param block the block that will be executed.  If nil, the currently registered block is unregistered.

 @note The block will remain registered for notifications until reset to nil, reset to another block.
 
 @todo I am not sure if the assciated objects are cleared when a dynamic library is unloaded.
 */
+ (void)wjh_setShouldTerminateBlock:(void (^)(WJHShouldTerminate *))block;

@end
