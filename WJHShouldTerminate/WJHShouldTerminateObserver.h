//
//  WJHShouldTerminateObserver.h
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
@interface WJHShouldTerminateObserver : NSObject

/**
 Manually unregister the block associated with this token.

 When this token deallocs, the registered block will automatically be unregistered.  However, there are times when it is advisable to unregister manually (e.g., to break retain cycles).
 */
- (void)unregister;

@end
