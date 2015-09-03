//
//  NSObject+WJHShouldTerminate.m
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "NSObject+WJHShouldTerminate.h"
#import "WJHShouldTerminate.h"
@import WJHAssocObj;

@implementation NSObject (WJHShouldTerminate)

+ (void)wjh_setBlock:(void (^)(WJHShouldTerminate *))block withKey:(void*)key {
    id token = block ? [WJHShouldTerminate registerBlock:block] : nil;
    WJHAssociateStrongly(self, key, token, YES);
}

+ (void)wjh_setShouldTerminateBlock:(void (^)(WJHShouldTerminate *))block {
    [self wjh_setBlock:block withKey:@selector(wjh_setBlock:withKey:)];
}

- (void)wjh_setShouldTerminateBlock:(void (^)(WJHShouldTerminate *))block {
    [self.class wjh_setBlock:block withKey:@selector(wjh_setShouldTerminateBlock:)];
}

@end
