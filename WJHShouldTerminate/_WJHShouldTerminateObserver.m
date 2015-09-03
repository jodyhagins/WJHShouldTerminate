//
//  _WJHShouldTerminateObserver.m
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "_WJHShouldTerminateObserver.h"
#import "WJHShouldTerminate.h"

@implementation _WJHShouldTerminateObserver {
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
    id strongObserver = observer;
    if (strongObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:strongObserver];
    }
}

@end
