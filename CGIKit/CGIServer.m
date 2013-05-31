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
#import <CGIStream/CGIStream.h>

NSString *CGIServerReloadNotification = @"info.maxchan.ohttpd.reload";
NSString *CGIServerStopNotification = @"info.maxchan.ohttpd.stop";
NSString *CGIServerWillStopNotification = @"info.maxchan.ohttpd.will-stop";
CGIServer *__thisServer;

@interface CGIServer ()

@property BOOL running;

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

- (id)init
{
    self = [super init];
    if (self) {
        self.handlers = [NSMutableDictionary dictionary];
        self.vhosts = [NSMutableArray array];
        self.listeners = [NSMutableArray array];
    }
    return self;
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

- (void)loadConfigFile:(NSString *)fileName lis:(NSMutableArray *)listeners vh:(NSMutableArray *)vhosts
{
    NSError *err = nil;
    fileName = (fileName == self.configFilePath) ? [fileName stringByExpandingTildeInPath] : [[self.configFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
    CGIFileStreamReader *lr = [[CGIFileStreamReader alloc] initWithFile:fileName
                                                                  error:&err];
    if (!lr)
    {
        eprintf("ohttpd: error: cannot open configure file: %s\n", CGICSTR(fileName));
        exit(1);
    }
    
    dbgprintf("ohttpd: info: opened configure file: %s\n", CGICSTR(fileName));
    
    NSUInteger status = 0; // 0 = outside
                           // 1 = Server block
    
    id cache = nil;
    NSUInteger lineno = 0;
    
    while (![lr endOfFile])
    {
        NSArray *line = [lr shellReadLine];
        lineno++;
        
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
                        eprintf("ohttpd: error: %s:%lu cannot parse config file: need port number after Listen\n", CGICSTR([fileName lastPathComponent]), lineno);
                        continue;
                    }
                    
                    int port = [line[1] intValue];
                    if (port <= (getuid()) ? 1024 : 0 || port > 65535)
                    {
                        eprintf("ohttpd: error: %s:%lu invalid port number for you: %d\n", CGICSTR([fileName lastPathComponent]), lineno, port);
                        continue;
                    }
                    
                    [listeners addObject:[[CGIListener alloc] initWithPort:port]];
                    dbgprintf("ohttpd: info: added listener at port %d\n", port);
                }
                else if ([line[0] isEqualToString:@"Include"])
                {
                    // Include
                    if ([line count] < 2)
                    {
                        eprintf("ohttpd: error: %s:%lu cannot parse config file: need file after Include\n", CGICSTR([fileName lastPathComponent]), lineno);
                        continue;
                    }
                    
                    [self loadConfigFile:line[1] lis:listeners vh:vhosts];
                }
                else if ([line[0] isEqualToString:@"Server"])
                {
                    // Virtual Host
                    if ([line count] < 2)
                    {
                        eprintf("ohttpd: error: %s:%lu cannot parse config file: need address after Server\n", CGICSTR([fileName lastPathComponent]), lineno);
                        continue;
                    }
                    
                    NSURL *listenURL = [NSURL URLWithString:line[1]];
                    if (!listenURL)
                    {
                        eprintf("ohttpd: error: %s:%lu invalid server listen url: %s\n", CGICSTR([fileName lastPathComponent]), lineno, CGICSTR(line[1]));
                        continue;
                    }
                    
                    status = 1;
                    cache = [[CGIVirtualHost alloc] initWithListenURL:listenURL];
                }
                else
                {
                    eprintf("ohttpd: error: %s:%lu unrecognized directive: %s\n", CGICSTR([fileName lastPathComponent]), lineno, CGICSTR(line[0]));
                    continue;
                }
                break;
            }
            case 1:
            {
                CGIVirtualHost *vh = cache;
                if ([line isEqualToArray:@[@"End", @"Server"]])
                {
                    // End Server line
                    dbgprintf("ohttpd: info: added server at %s\n", CGICSTR([vh.listenURL absoluteString]));
                    [vhosts addObject:vh];
                    cache = nil;
                    status = 0;
                }
                else if ([line[0] isEqualToString:@"Index"])
                {
                    if ([line count] < 2)
                    {
                        eprintf("ohttpd: error: %s:%lu cannot parse config file: need port number after Index\n", CGICSTR([fileName lastPathComponent]), lineno);
                        continue;
                    }
                    vh.indexPages = [[line subarrayWithRange:NSMakeRange(1, [line count] - 1)] arrayByAddingObjectsFromArray:vh.indexPages];
                }
                else if ([line[0] isEqualToString:@"DocumentRoot"])
                {
                    if ([line count] < 2)
                    {
                        eprintf("ohttpd: error: %s:%lu cannot parse config file: need port number after DocumentRoot\n", CGICSTR([fileName lastPathComponent]), lineno);
                        continue;
                    }
                    vh.documentRoot = [line[1] stringByExpandingTildeInPath];
                }
                else
                {
                    eprintf("ohttpd: error: %s:%lu unrecognized directive: %s\n", CGICSTR([fileName lastPathComponent]), lineno, CGICSTR(line[0]));
                    continue;
                }
                break;
            }
        }
    }
}

- (void)reload
{
    // Suspend messages
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc setSuspended:YES];
    
    NSMutableArray *listeners = [NSMutableArray array];
    NSMutableArray *vhosts = [NSMutableArray array];
    
    NSError *err = nil;
    [self loadConfigFile:self.configFilePath lis:listeners vh:vhosts];
    
    if (!([listeners count] || [vhosts count]))
    {
        eprintf("ohttpd: error: No server or listening port found in config file.\n");
        if (!([self.vhosts count] && [self.listeners count]))
            exit(1);
    }
    
    if ([self.listeners count])
    {
        for (CGIListener *listener in self.listeners)
        {
            err = nil;
            if (![listener unbindWithError:&err])
            {
                eprintf("ohttpd: error: failed to unbind from port %u: %s\n", listener.port, CGICSTR([err description]));
            }
        }
    }
    
    [self.listeners removeAllObjects];
    [self.vhosts setArray:vhosts];
    
    for (CGIListener *listener in listeners)
    {
        err = nil;
        if ([listener bindWithError:&err])
        {
            [self.listeners addObject:listener];
        }
        else
        {
            eprintf("ohttpd: error: failed to bind to port %u: %s\n", listener.port, CGICSTR([err description]));
        }
    }
    
    if (!([self.vhosts count] && [self.listeners count]))
    {
        eprintf("ohttpd: error: no successful server or port.\n");
        exit(1);
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
