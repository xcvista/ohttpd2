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
#import "CGILineReader.h"

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
    
    // Load the config file
    [self reload];
    
    dbgprintf("ohttpd: info: server running.\n");
    
    // Start the run loop.
    
    self.running = YES;
    NSRunLoop *rl = [NSRunLoop mainRunLoop];
    
    while (self.running && [rl runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]]);
    
    // Tear down notification.
    [dnc removeObserver:self];
    
    dbgprintf("ohttpd: info: server stopped.\n");
    
    exit(0);
}

- (void)reload
{
    // Suspend messages
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc setSuspended:YES];
    
    NSMutableArray *listeners = [NSMutableArray array];
    NSMutableArray *vhosts = [NSMutableArray array];
    
    NSError *err = nil;
    CGILineReader *lr = [[CGILineReader alloc] initWithFile:self.configFilePath
                                                      error:&err];
    if (!lr)
    {
        eprintf("ohttpd: error: cannot open configure file: %s\n", CGICSTR(self.configFilePath));
        exit(1);
    }
    
    dbgprintf("ohttpd: info: opened configure file: %s\n", CGICSTR(self.configFilePath));
    
    NSUInteger status = 0; // 0 = outside
                           // 1 = Server block
    
    id cache = nil;
    
    while (![lr endOfFile])
    {
        NSArray *line = [lr shellReadLine];
        
        if (![line count])
            continue;
        
        switch (status)
        {
            case 0:
            {
                if ([line[0] isEqualToString:@"Listen"])
                {
                    // Listener
                    if ([line count] < 2)
                    {
                        eprintf("ohttpd: error: cannot parse config file: need port number after Listen\n");
                        continue;
                    }
                    
                    int port = [line[1] intValue];
                    if (port <= (getuid()) ? 1024 : 0 || port > 65535)
                    {
                        eprintf("ohttpd: error: invalid port number for you: %d\n", port);
                        continue;
                    }
                    
                    [listeners addObject:[[CGIListener alloc] initWithPort:port]];
                    dbgprintf("ohttpd: info: added listener at port %d\n", port);
                }
                else if ([line[0] isEqualToString:@"Server"])
                {
                    // Virtual Host
                    if ([line count] < 2)
                    {
                        eprintf("ohttpd: error: cannot parse config file: need port number after Server\n");
                        continue;
                    }
                    
                    NSURL *listenURL = [NSURL URLWithString:line[1]];
                    if (!listenURL)
                    {
                        eprintf("ohttpd: error: invalid server listen url: %s\n", CGICSTR(line[1]));
                        continue;
                    }
                    
                    cache = [[CGIVirtualHost alloc] initWithListenURL:listenURL];
                }
            }
            case 1:
            {
                
            }
        }
    }
    
    // Resume messages
    [dnc setSuspended:NO];
}

- (void)stop
{
    dbgprintf("ohttpd: info: server will stop.\n");
    
    // Ask everything to stop.
    [[NSNotificationCenter defaultCenter] postNotificationName:CGIServerWillStopNotification
                                                        object:self];
    
    self.running = NO;
}

@end
