//
//  WJHShouldTerminate.h
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>

extern double WJHShouldTerminateVersionNumber();
extern unsigned char const * WJHShouldTerminateVersionString();

#import <WJHShouldTerminate/WJHShouldTerminateToken.h>
#import <WJHShouldTerminate/WJHShouldTerminateObserver.h>
#import <WJHShouldTerminate/NSObject+WJHShouldTerminate.h>


@interface WJHShouldTerminate : NSObject

/**
 Issue a request to terminate the application.

 When this method is invoked, WJHShouldTerminateNotification is posted to the default notification center.  The object contained in the notification will be an instance of WJHShouldTerminate.

 Normally, this will only be called in the AppDelegate applicationShouldTerminate: method.

 Observers of that notification can use the WJHShouldTerminate instance to authorize, delay, or deny application termination.

 Observers do not have to respond, but if they pause termination, they must respond at some point, by either canceling or resuming the termination process.

 @return A status indicating how the termination request should be interpreted.

 @note If this method returns NSTerminateLater, then the application will be running in NSModalPanelRunLoopMode until the termination request has been completed or canceled.
 */
+ (NSApplicationTerminateReply)requestTerminationForApplication:(NSApplication*)application;

/**
 Register a block that will be executed whenever a request to terminate the application is made.

 @param block the block that will be executed when the application has been requested to shotdown.  Must not be nil.

 @return An auto-released object that will automatically unregister the block when the object is deallocated.  As long as the returned object remains alive, the block will remain registered.
 */
+ (WJHShouldTerminateObserver*)registerBlock:(void(^)(WJHShouldTerminate *st))block;

/**
 Pause (or postpone) application termination.

 Calling this method will delay the replyToApplicationShouldTerminate: response currently being expected by the system.

 Basically, a unique token will be created, and returned to the caller.  When the caller has decided that the termination no longer has to wait, it can be resumed with the same unique token returned by the pause request.

 This method must only be called in an observer callback of the WJHShouldTerminateNotification handler, and should be called immediately (i.e., not in another thread or queue).

 @return a token that must be used to resume or cancel termination.

 @note If the caller does not resume or cancel termination with the same token, the application termination not complete it termination process, and will (eventually) cancel the termination on its own.
 */
- (WJHShouldTerminateToken*)pauseTermination;

/**
 Cancel the termination request.

 This method can be called immediately upon receit of the termination request, or it can be called any time afer pausing.  Like a fraternity black ball, it only takes one cancel response to deny the termination request.

 This method can be called at any time, from any thread.
 */
- (void)cancelTermination;

/**
 Resume the termination process.

 There must be a resume for each pause in order for the termination to proceed.

 This method can be called at any time, from any thread.
 */
- (void)resumeTermination:(WJHShouldTerminateToken*)token;

@end


#pragma mark - Notifications

/**
 Notification sent to indicate that the application wants to terminate.

 The notification object is an instance of WJHShouldTerminate.
 */
extern NSString * const WJHShouldTerminateNotification;
