//
//  CGIHTTPContext.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIHTTPContext.h"
#import "CGIHTTPRequest.h"
#import "CGIHTTPResponse.h"
#import "CGIServer.h"
#import "CGIVirtualHost.h"

static inline BOOL xor(BOOL a, BOOL b)
{
    return (a && !b) || (!a && b);
}

@implementation CGIHTTPContext

- (id)initWithHTTPRequest:(CGIHTTPRequest *)request queue:(dispatch_queue_t)queue
{
    if (self = [super init])
    {
        self.request = request;
        self.response = [[CGIHTTPResponse alloc] initWithRequest:self.request];
        self.mainQueue = queue;
    }
    return self;
}

- (BOOL)matchForVirtualHost
{
    CGIServer *server = [CGIServer server];
    
    NSMutableArray *generics = [NSMutableArray array];
    
    for (CGIVirtualHost *vhost in server.vhosts)
    {
        if (xor(self.request.SSL, [[vhost.listenURL scheme] compare:@"https:" options:NSCaseInsensitiveSearch] == NSOrderedSame))
        {
            // SSL will not match non-SSL.
            continue;
        }
        
        if ([vhost.listenURL.host rangeOfString:@"*"].location != NSNotFound)
        {
            // Generic
            [generics addObject:vhost];
            continue;
        }
        
        if ([vhost.listenURL.host compare:self.request.allHeaderFields[@"Host"] options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            // Match
            self.server = vhost;
            return YES;
        }
    }
    
    for (CGIVirtualHost *vhost in generics)
    {
        if ([[NSPredicate predicateWithFormat:@"self LIKE %@", vhost.listenURL.host] evaluateWithObject:self.request.allHeaderFields[@"Host"]])
        {
            // Match
            self.server = vhost;
            return YES;
        }
    }
    
    return NO;
}

- (void)process
{
    [NSException raise:@"test" format:@"test purpose"];
}

@end
