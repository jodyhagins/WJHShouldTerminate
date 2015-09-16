//
//  NSObject+WJHShouldTerminate.m
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "NSObject+WJHShouldTerminate.h"
#import "WJHShouldTerminate.h"
#import <objc/runtime.h>

@implementation NSObject (WJHShouldTerminate)

+ (void)wjh_setBlock:(void (^)(WJHShouldTerminate *))block onObject:(id)object {
    id token = block ? [WJHShouldTerminate registerBlock:block] : nil;
    objc_setAssociatedObject(object, _cmd, token, OBJC_ASSOCIATION_RETAIN);
}

+ (void)wjh_setShouldTerminateBlock:(void (^)(WJHShouldTerminate *))block {
    [self wjh_setBlock:block onObject:self];
}

- (void)wjh_setShouldTerminateBlock:(void (^)(WJHShouldTerminate *))block {
    [self.class wjh_setBlock:block onObject:self];
}

@end
