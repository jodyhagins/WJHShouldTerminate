//
//  WJHShouldTerminateTests.m
//  WJHShouldTerminateTests
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
@import WJHShouldTerminate;

@interface WJHShouldTerminateTests : XCTestCase
@property (atomic, assign) BOOL replyReceived;
@property (atomic, assign) BOOL replyValue;
@end

@implementation WJHShouldTerminateTests {
    id app;
    void (^replyBlock)(BOOL);
}

// Method implemented to receive callbacks as if "app" were the actual application
- (void)replyToApplicationShouldTerminate:(BOOL)shouldTerminate {
    self.replyValue = shouldTerminate;
    self.replyReceived = YES;
    if (replyBlock) replyBlock(shouldTerminate);
}

- (void)expectReply {
    [self keyValueObservingExpectationForObject:self keyPath:@"replyReceived" expectedValue:@YES];
}

- (void)expectNotification:(void(^)(WJHShouldTerminate *st))block {
    [self expectationForNotification:WJHShouldTerminateNotification object:nil handler:^BOOL(NSNotification *notification) {
        XCTAssertTrue([notification.object isKindOfClass:[WJHShouldTerminate class]]);
        if (block) block(notification.object);
        return YES;
    }];
}

- (void)setUp {
    [super setUp];
    app = self;
}

- (void)testRequestSendsNotification {
    [self expectNotification:nil];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testNoResponseAllowsTermination {
    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.replyValue);
}

- (void)testReturnedTokenLivesUntilAutoReleased {
    __block NSUInteger count = 0;
    @autoreleasepool {
        [self expectReply];
        [WJHShouldTerminate registerBlock:^(WJHShouldTerminate *st) {
            ++count;
        }];
        [WJHShouldTerminate requestTerminationForApplication:app];
        [self waitForExpectationsWithTimeout:1 handler:nil];
        XCTAssertEqual(1, count);

        [self expectReply];
        [WJHShouldTerminate requestTerminationForApplication:app];
        [self waitForExpectationsWithTimeout:1 handler:nil];
        XCTAssertEqual(2, count);
    }

    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(2, count);
}

- (void)testNSObjectCategoryHoldsBlockUntilReleased {
    __block NSUInteger count = 0;
    NSUUID *object = [NSUUID UUID];
    @autoreleasepool {
        [self expectReply];
        [object wjh_setShouldTerminateBlock:^(WJHShouldTerminate *st) {
            ++count;
        }];
        [WJHShouldTerminate requestTerminationForApplication:app];
        [self waitForExpectationsWithTimeout:1 handler:nil];
        XCTAssertEqual(1, count);

        [self expectReply];
        [WJHShouldTerminate requestTerminationForApplication:app];
        [self waitForExpectationsWithTimeout:1 handler:nil];
        XCTAssertEqual(2, count);
    }

    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(3, count);

    [object wjh_setShouldTerminateBlock:nil];

    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(3, count);
}

- (void)testImmediateCancelTermination {
    NSMutableSet *tokens = [NSMutableSet set];
    [self expectNotification:^(WJHShouldTerminate *st) {
        for (int i = 0; i < 10; ++i) {
            if (i == 5) [st cancelTermination];
            else [tokens addObject:[st pauseTermination]];
        }
    }];
    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertFalse(self.replyValue);
}

- (void)testDelayedCancelTermination {
    NSMutableSet *tokens = [NSMutableSet set];
    [self expectNotification:^(WJHShouldTerminate *st) {
        for (int i = 0; i < 10; ++i) {
            [tokens addObject:[st pauseTermination]];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssertFalse(self.replyReceived);
            [st cancelTermination];
        });
    }];
    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertFalse(self.replyValue);
}

- (void)testManualResumeAllowsTermination {
    NSMutableArray *tokens = [NSMutableArray array];
    [self expectNotification:^(WJHShouldTerminate *st) {
        for (int i = 0; i < 10; ++i) {
            [tokens addObject:[st pauseTermination]];
        }
        __block NSUInteger index = 0;
        __block void (^block)(void) = ^{
            XCTAssertFalse(self.replyReceived);
            NSLog(@"Index %lu", (unsigned long)index);
            WJHShouldTerminateToken *token = tokens[index];
            [st resumeTermination:token];
            if (++index < tokens.count) dispatch_async(dispatch_get_main_queue(), block);
            else block = nil;
        };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }];
    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.replyValue);
}

- (void)testTokenDeallocResumeAllowsTermination {
    NSMutableSet *tokens = [NSMutableSet set];
    [self expectNotification:^(WJHShouldTerminate *st) {
        for (int i = 0; i < 10; ++i) {
            [tokens addObject:[st pauseTermination]];
        }
        __block void (^block)(void) = ^{
            [tokens removeAllObjects];
        };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }];
    [self expectReply];
    [WJHShouldTerminate requestTerminationForApplication:app];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.replyValue);
}

@end
