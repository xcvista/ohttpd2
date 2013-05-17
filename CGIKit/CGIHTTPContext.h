//
//  CGIHTTPContext.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@class CGIHTTPRequest;
@class CGIHTTPResponse;
@class CGIVirtualHost;

@interface CGIHTTPContext : NSObject

@property CGIHTTPRequest *request;
@property CGIHTTPResponse *response;
@property CGIVirtualHost *server;
@property dispatch_queue_t mainQueue;

- (id)initWithHTTPRequest:(CGIHTTPRequest *)request virtualHost:(CGIVirtualHost *)vhost queue:(dispatch_queue_t)queue;

@end
