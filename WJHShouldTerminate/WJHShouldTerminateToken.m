//
//  WJHShouldTerminateToken.m
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "WJHShouldTerminateToken.h"
#import "WJHShouldTerminate.h"

@interface WJHShouldTerminate()
- (void)tokenWillDealloc:(__unsafe_unretained WJHShouldTerminateToken*)token;
@end

@interface WJHShouldTerminateToken()
- (instancetype)initWithShouldTerminate:(WJHShouldTerminate*)shouldTerminate;
@end


@implementation WJHShouldTerminateToken {
    WJHShouldTerminate *shouldTerminate;
}

- (instancetype)initWithShouldTerminate:(WJHShouldTerminate*)st {
    if (self = [super init]) {
        shouldTerminate = st;
    }
    return self;
}

- (void)cancel {
    [shouldTerminate cancelTermination];
}

- (void)resume {
    [shouldTerminate resumeTermination:self];
}

- (void)dealloc {
    [shouldTerminate tokenWillDealloc:self];
}

@end
