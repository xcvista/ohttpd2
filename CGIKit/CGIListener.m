//
//  CGIListener.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIListener.h"
#import "CGIServer.h"
#import "CGIConnection.h"

#ifndef GNUSTEP

// OS X

#import <GCDAsyncSocket/GCDAsyncSocket.h>

@interface CGIListener () <GCDAsyncSocketDelegate>

@property GCDAsyncSocket *socket;

@end

@implementation CGIListener

- (id)initWithPort:(uint16_t)port
{
    if (self = [super init])
    {
        self.port = port;
        
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        self.connections = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(__unbindWithNotification:)
                                                     name:CGIServerWillStopNotification
                                                   object:nil];
    }
    return self;
}

- (BOOL)bindWithError:(NSError *__autoreleasing *)error
{
    return [self.socket acceptOnPort:self.port error:error];
}

- (BOOL)unbindWithError:(NSError *__autoreleasing *)error
{
    [self.socket disconnectAfterReadingAndWriting];
    return YES;
}

- (void)__unbindWithNotification:(NSNotification *)aNotification
{
    [self.socket disconnect];
    
    for (NSInteger i = [self.connections count] - 1; i > 0; i--)
    {
        CGIConnection *conn = self.connections[i];
        [conn stop];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    CGIConnection *connection = [[CGIConnection alloc] initWithSocket:newSocket listener:self];
    if (!connection)
    {
        eprintf("ohttpd: error: dropped connection.");
        [newSocket disconnect];
    }
    [self.connections addObject:connection];
    [connection run];
}

- (void)dealloc
{
    if (self.binded)
        [self __unbindWithNotification:nil];
}

- (void)connectionDidFinish:(CGIConnection *)connection
{
    [self.connections removeObject:connection];
}

@end

#else

// GNUstep

#endif
