//
//  TJBackgroundTask.h
//  Close-up
//
//  Created by Tim Johnsen on 5/26/18.
//

#import <Foundation/Foundation.h>

@interface TJBackgroundTask : NSObject

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name
           expirationHandler:(dispatch_block_t)expirationHandler NS_DESIGNATED_INITIALIZER;

- (void)endTask;

@end
