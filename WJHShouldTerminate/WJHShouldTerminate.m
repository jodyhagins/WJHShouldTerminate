//
//  WJHShouldTerminate.m
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "WJHShouldTerminate.h"
#import "_WJHShouldTerminateObserver.h"


#pragma mark - WJHShouldTerminateToken Private API

@interface WJHShouldTerminateToken()
- (instancetype)initWithShouldTerminate:(WJHShouldTerminate*)shouldTerminate;
@end


#pragma mark - WJHShouldTerminate Private API

@interface WJHShouldTerminate()
@property (nonatomic, strong) NSHashTable *pending;
@property (nonatomic, strong) NSApplication *application;
/**
 Strong reference to self.

 Keeps the object alive until it has received a definitive response from observers.
 */
@property (nonatomic, strong) id myself;
@end


#pragma mark - WJHShouldTerminate

@implementation WJHShouldTerminate


#pragma mark Public Impl

+ (NSApplicationTerminateReply)requestTerminationForApplication:(NSApplication *)application {
    WJHShouldTerminate *shouldTerminate = [[self alloc] initWithApplication:application];
    [shouldTerminate performBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:WJHShouldTerminateNotification object:shouldTerminate];
        [shouldTerminate checkPending];
    }];
    return NSTerminateLater;
}

+ (id)registerBlock:(void (^)(WJHShouldTerminate *))block {
    NSAssert(block != nil, @"Must provide block");
    return [[_WJHShouldTerminateObserver alloc] initWithBlock:block];
}

- (WJHShouldTerminateToken*)pauseTermination {
    WJHShouldTerminateToken *token = [[WJHShouldTerminateToken alloc] initWithShouldTerminate:self];
    [self performBlock:^{
        [self.pending addObject:token];
    }];
    return token;
}

- (void)cancelTermination {
    [self performBlock:^{
        [self replyToApplicationShouldTerminate:NO];
    }];
}

- (void)resumeTermination:(WJHShouldTerminateToken*)token {
    [self performBlock:^{
        [self.pending removeObject:token];
        [self checkPendingNow];
    }];
}


#pragma mark Private Impl

- (instancetype)initWithApplication:(NSApplication*)application {
    if (self = [super init]) {
        // Hold simple pointers in the has table.  Zeroing-weak references do not work because while they get zeroed out, the count does not get immediately updated, resulting in a linear scan of the hash table to see if all objects have been deallocated.  This is OK since we are only inserting our own token objects, which remove themselves when they dealloc.
        _pending = [NSHashTable hashTableWithOptions:NSPointerFunctionsOpaqueMemory|NSPointerFunctionsOpaquePersonality];
        _application = application;
        _myself = self;
    }
    return self;
}

- (void)performBlock:(void(^)(void))block {
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void)checkPending {
    [self performBlock:^{
        [self checkPendingNow];
    }];
}

- (void)checkPendingNow {
    // While the NSHashTable will zero out the weak references, it does not update its count until some time later.  We need an accurate count now.
    NSUInteger count = 0;
    for (id __attribute__((unused)) obj in self.pending) {
        ++count;
    }
    if (count == 0) {
        [self replyToApplicationShouldTerminate:YES];
    }
}

- (void)replyToApplicationShouldTerminate:(BOOL)shouldTerminate {
    if (self.myself) {
        NSApplication *app = self.application;
        self.pending = nil;
        self.application = nil;
        self.myself = nil;
        [app replyToApplicationShouldTerminate:shouldTerminate];
    }
}

- (void)tokenWillDealloc:(__unsafe_unretained WJHShouldTerminateToken*)token {
    [self performBlock:^{
        [self.pending removeObject:token];
        [self checkPendingNow];
    }];
}
@end


#pragma mark - Constant Definitions

NSString * const WJHShouldTerminateNotification = @"wjh.notification.shouldTerminate";
