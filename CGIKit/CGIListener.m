//
//  CGIListener.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIListener.h"
#import "CGIServer.h"

#ifndef GNUSTEP
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#endif

@implementation CGIListener
{
    NSMutableArray *listeningSockets;
}

- (id)initWithPort:(uint16_t)port
{
    if (self = [super init])
    {
        self.port = port;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(__unbindWithNotification:)
                                                     name:CGIServerWillStopNotification
                                                   object:nil];
    }
    return self;
}

- (BOOL)bindWithError:(NSError *__autoreleasing *)error
{
#ifdef GNUSTEP
    
#else
    
#endif
}

- (BOOL)unbindWithError:(NSError *__autoreleasing *)error
{
#ifdef GNUSTEP
    
#else
    
#endif
}

- (void)__unbindWithNotification:(NSNotification *)aNotification
{
    NSError *err = nil;
    if (![self unbindWithError:&err])
    {
        eprintf("ohttpd: error: cannot unbind from port %u: %s", self.port, CGICSTR([err description]));
    }
}

- (void)dealloc
{
    if (self.binded)
        [self unbindWithError:NULL];
}

@end
