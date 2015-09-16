//
//  WJHShouldTerminate.m
//  WJHShouldTerminate
//
//  Copyright (c) 2015 Jody Hagins. All rights reserved.
//

#import "WJHShouldTerminate.h"
#import "WJHShouldTerminateObserver.h"


#pragma mark - WJHShouldTerminateToken Private API

@interface WJHShouldTerminateToken()
- (instancetype)initWithShouldTerminate:(WJHShouldTerminate*)shouldTerminate;
@end


#pragma mark - WJHShouldTerminateObserver Private API

@interface WJHShouldTerminateObserver()
- (instancetype)initWithBlock:(void (^)(WJHShouldTerminate *))block;
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

#pragma mark - Framework Initialization

static double versionNumber;
double WJHShouldTerminateVersionNumber()
{
    return versionNumber;
}

static char * versionString;
unsigned char const * WJHShouldTerminateVersionString()
{
    return (unsigned char *)versionString;
}

__attribute__((constructor))
static void init()
{
    @autoreleasepool {
        NSBundle *bundle = [NSBundle bundleForClass:[WJHShouldTerminate class]];
        NSString *buildVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *releaseVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        releaseVersion = [NSString stringWithFormat:@"%@ (%@)", releaseVersion, buildVersion];

        versionNumber = [buildVersion doubleValue];
        versionString = strdup([releaseVersion cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

__attribute__((destructor))
static void fini()
{
    if (versionString) {
        free(versionString);
        versionString = NULL;
    }
}


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
    return [[WJHShouldTerminateObserver alloc] initWithBlock:block];
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
        _pending = [NSHashTable weakObjectsHashTable];
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
    if ([self.pending anyObject] == nil) {
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

@end


#pragma mark - Constant Definitions

NSString * const WJHShouldTerminateNotification = @"wjh.notification.shouldTerminate";
