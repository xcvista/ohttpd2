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

@end
