//
//  CGIHTTPResponse.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIHTTPResponse.h"
#import "CGIHTTPRequest.h"

#define CGITestAssign(to, from) do { id __from = from; \
if (__from) to = __from; \
} while(0)

@implementation CGIHTTPResponse

- (id)init
{
    self = [super init];
    if (self) {
        self.allHeaderFields = [NSMutableDictionary dictionary];
        self.statusCode = 200;
        self.protocolVersion = @"HTTP/1.0";
        self.allHeaderFields[@"Server"] = @"ohttpd/2.0";
    }
    return self;
}

- (id)initWithRequest:(CGIHTTPRequest *)request
{
    if (self = [self init])
    {
        if (request)
        {
            self.protocolVersion = request.protocolVersion;
            CGITestAssign(self.allHeaderFields[@"Connection"], request.allHeaderFields[@"Connection"]);
            CGITestAssign(self.allHeaderFields[@"Set-Cookie"], request.allHeaderFields[@"Cookie"]);
        }
    }
    return self;
}

+ (instancetype)HTTP100Response
{
    CGIHTTPResponse *response = [[self alloc] init];
    response.statusCode = 100;
    response.protocolVersion = @"HTTP/1.1";
    return response;
}

+ (instancetype)HTTP400Response
{
    CGIHTTPResponse *response = [[self alloc] init];
    response.statusCode = 400;
    response.protocolVersion = @"HTTP/1.0";
    response.allHeaderFields[@"Content-Type"] = @"text/html; charset=utf-8";
    response.allHeaderFields[@"Connection"] = @"close";
    response.responseBody = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"400" ofType:@"html"]];
    return response;
}

+ (instancetype)HTTP403Response
{
    CGIHTTPResponse *response = [[self alloc] init];
    response.statusCode = 403;
    response.protocolVersion = @"HTTP/1.0";
    response.allHeaderFields[@"Content-Type"] = @"text/html; charset=utf-8";
    response.allHeaderFields[@"Connection"] = @"close";
    response.responseBody = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"403" ofType:@"html"]];
    return response;
}

+ (instancetype)HTTP500Response
{
    CGIHTTPResponse *response = [[self alloc] init];
    response.statusCode = 500;
    response.protocolVersion = @"HTTP/1.0";
    response.allHeaderFields[@"Content-Type"] = @"text/html; charset=utf-8";
    response.allHeaderFields[@"Connection"] = @"close";
    response.responseBody = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"500" ofType:@"html"]];
    return response;
}

@end
