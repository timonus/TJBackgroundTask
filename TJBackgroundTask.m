//
//  TJBackgroundTask.m
//  Close-up
//
//  Created by Tim Johnsen on 5/26/18.
//

#import "TJBackgroundTask.h"
#import <os/lock.h>

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@implementation TJBackgroundTask {
    UIBackgroundTaskIdentifier _taskIdentifier;
    os_unfair_lock _lock;
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
        _lock = OS_UNFAIR_LOCK_INIT;
        
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
    os_unfair_lock_lock(&_lock);
    if (_taskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_taskIdentifier];
        _taskIdentifier = UIBackgroundTaskInvalid;
    }
    os_unfair_lock_unlock(&_lock);
}

- (void)dealloc
{
    [self endTask];
}

@end
