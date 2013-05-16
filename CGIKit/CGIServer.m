//
//  CGIServer.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIServer.h"
#import "CGIListener.h"
#import "CGIVirtualHost.h"

NSString *CGIServerReloadNotification = @"info.maxchan.ohttpd.reload";
NSString *CGIServerStopNotification = @"info.maxchan.ohttpd.stop";
NSString *CGIServerWillStopNotification = @"info.maxchan.ohttpd.will-stop";
CGIServer *__thisServer;

@interface CGIServer ()

@property BOOL running;
@property NSMutableArray *listeners;
@property NSMutableArray *vhosts;

@end

@implementation CGIServer

+ (instancetype)server
{
    if (!__thisServer)
        __thisServer = [[self alloc] init];
    return __thisServer;
}

- (void)__didReceiveReloadNotification:(NSNotification *)notification
{
    [self reload];
}

- (void)__didReceiveStopNotification:(NSNotification *)notification
{
    [self stop];
}

- (void)start
{
    // Load the config file
    [self reload];
    
    // Set up notifications
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self
            selector:@selector(__didReceiveReloadNotification:)
                name:CGIServerReloadNotification
              object:self.instanceIdentifier];
    [dnc addObserver:self
            selector:@selector(__didReceiveStopNotification:)
                name:CGIServerStopNotification
              object:self.instanceIdentifier];
    
    eprintf("ohttpd: info: server running.\n");
    
    // Start the run loop.
    
    self.running = YES;
    NSRunLoop *rl = [NSRunLoop mainRunLoop];
    
    while (self.running && [rl runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]]);
    
    // Tear down notification.
    [dnc removeObserver:self];
    
    eprintf("ohttpd: info: server stopped.\n");
    
    exit(0);
}

- (void)reload
{
    // Stop current servers
}

- (void)stop
{
    eprintf("ohttpd: info: server will stop.\n");
    
    // Ask everything to stop.
    [[NSNotificationCenter defaultCenter] postNotificationName:CGIServerWillStopNotification
                                                        object:self];

    self.running = NO;
}

@end
