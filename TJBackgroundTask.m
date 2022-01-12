//
//  TJBackgroundTask.m
//  Close-up
//
//  Created by Tim Johnsen on 5/26/18.
//

#import "TJBackgroundTask.h"

@implementation TJBackgroundTask {
    UIBackgroundTaskIdentifier _taskIdentifier;
}

- (instancetype)init
{
    return [self initWithName:nil
            expirationHandler:nil];
}

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name
            expirationHandler:nil];
}

- (instancetype)initWithName:(NSString *const)name expirationHandler:(dispatch_block_t)expirationHandler
{
    BOOL check;
    if (@available(iOS 13.0, *)) {
        check = YES;
    } else {
        check = [NSThread isMainThread];
    }
    
    if (check) {
        // Don't start a new background task if fewer than 5 seconds are available.
        // https://developer.apple.com/videos/play/wwdc2020/10078/?t=640
        // (It's not safe to call this off the main thread on iOS 12)
        if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 5.0) {
            return nil;
        }
    }
    
    if (self = [super init]) {
        __weak TJBackgroundTask *weakSelf = self;
        _taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:name
                                                                       expirationHandler:^{
            if (expirationHandler) {
                expirationHandler();
            }
            [weakSelf endTask];
        }];
    }
    return self;
}

- (void)endTask
{
    @synchronized (self) {
        if (_taskIdentifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:_taskIdentifier];
            _taskIdentifier = UIBackgroundTaskInvalid;
        }
    }
}

- (void)dealloc
{
    [self endTask];
}

@end
