//
//  WJHShouldTerminateObserver.m
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "WJHShouldTerminateObserver.h"
#import "WJHShouldTerminate.h"

@interface WJHShouldTerminateObserver()
- (instancetype)initWithBlock:(void (^)(WJHShouldTerminate *))block;
@end


@implementation WJHShouldTerminateObserver {
    __weak id observer;
}

- (instancetype)initWithBlock:(void (^)(WJHShouldTerminate *))block {
    if (self = [super init]) {
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:WJHShouldTerminateNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            block(note.object);
        }];
    }
    return self;
}

- (void)dealloc {
    [self unregister];
}

- (void)unregister {
    id strongObserver = observer;
    if (strongObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:strongObserver];
    }
    observer = nil;
}

@end
