//
//  WJHShouldTerminateToken.h
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A token returned when pausing application termination via -[WJHShouldTerminate pauseTermination].
 */
@interface WJHShouldTerminateToken : NSObject

/*
 Use the token to cancel the original process termination request.

 This method can be called at any time, from any thread.
 */
- (void)cancel;

/*
 Use the token to resume the original process termination request.

 This method can be called at any time, from any thread.

 @note If the token deallocs before issuing either a cancel or resume, it will automatically resume the termination in its dealloc method.
 */
- (void)resume;

@end
