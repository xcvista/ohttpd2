//
//  CGIConnection.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIConnection.h"
#import "CGIListener.h"
#import "CGIHTTPRequest.h"
#import "CGIHTTPResponse.h"
#import "CGIHTTPContext.h"
#import "CGIHTTPStatus.h"
#import "CGIVirtualHost.h"

#ifndef GNUSTEP

enum CGIConnectionStatus : long
{
    readingRequestInit,
    readingRequestHeader,
    readingRequestBody,
    processing,
    writing,
    cleaningUp
};

@interface CGIConnection () <GCDAsyncSocketDelegate>

@property CGIHTTPRequest *request;
@property CGIHTTPResponse *response;
@property CGIHTTPContext *context;
@property enum CGIConnectionStatus status;
@property NSDate *keepAliveUntil;
@property dispatch_source_t timer;

@end

@implementation CGIConnection

- (id)initWithSocket:(GCDAsyncSocket *)socket listener:(CGIListener *)listener
{
    if (self = [super init])
    {
        self.socket = socket;
        self.dispatchQueue = dispatch_queue_create(NULL, nil);
        self.listener = listener;
        
        [socket synchronouslySetDelegate:self delegateQueue:self.dispatchQueue];
        [socket setUserData:self];
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *line = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    
    if (self.status < readingRequestBody)
        dbgprintf("ohttpd: info: %s:%u said: %s\n",
                  CGICSTR(self.socket.connectedHost),
                  self.socket.connectedPort,
                  CGICSTR([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]));
    else
        dbgprintf("ohttpd: info: %s:%u sent %lu bytes.\n",
                  CGICSTR(self.socket.connectedHost),
                  self.socket.connectedPort,
                  [data length]);
    
    [self stopTimer];
    
    switch (self.status)
    {
        case readingRequestInit:
        {
            do
            {
                self.request = nil;
                CGIHTTPRequest *request = [[CGIHTTPRequest alloc] init];
                
                line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSScanner *scanner = [NSScanner scannerWithString:line];
                NSString *buf;
                
                // Scan for protocol header
                if (![scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&buf])
                    break;
                request.protocolVersion = buf;
                [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                
                // Scan for request path
                if (![scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&buf])
                    break;
                request.requestPath = buf;
                [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                
                // Scan for protocol version
                if (![scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&buf])
                    break;
                request.protocolVersion = buf;
                
                if ([self.socket isSecure])
                    self.request.SSL = YES;
                
                self.request = request;
                
            } while (0);
            
            if (!self.request)
            {
                self.status = writing;
                self.response = [CGIHTTPResponse HTTP400Response];
                [self sendResponse];
            }
            else
            {
                self.status = readingRequestHeader;
                [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:self.status];
            }
            
            break;
        }
        case readingRequestHeader:
        {
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            do
            {
                if ([line length] < 1)
                {
                    // Empty line, okay we got to the end of header.
                    
                    if ([self.request.allHeaderFields[@"Host"] length] <= 0)
                    {
                        self.request = nil;
                        break;
                    }
                    
                    if ([self.request.allHeaderFields[@"Content-Length"] integerValue] > 0)
                    {
                        if ([self.request.allHeaderFields[@"Expect"] isEqualToString:@"100-continue"])
                        {
                            self.response = [CGIHTTPResponse HTTP100Response];
                            self.status = writing;
                            [self sendResponse];
                        }
                        else
                        {
                            self.status = readingRequestBody;
                            [self.socket readDataToLength:[self.request.allHeaderFields[@"Content-Length"] integerValue]
                                              withTimeout:-1
                                                      tag:self.status];
                        }
                    }
                    else
                    {
                        self.status = processing;
                        [self processRequest];
                    }
                }
                
                NSRange colon = [line rangeOfString:@":"];
                if (colon.location == NSNotFound)
                {
                    self.response = nil;
                    break;
                }
                
                NSString *key = [[line substringToIndex:colon.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *value = [[line substringFromIndex:NSMaxRange(colon)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                id current = self.request.allHeaderFields[key];
                if (current)
                {
                    if ([current isKindOfClass:[NSArray class]])
                    {
                        self.request.allHeaderFields[key] = [current arrayByAddingObject:value];
                    }
                    else
                    {
                        self.request.allHeaderFields[key] = @[current, value];
                    }
                }
                else
                    self.request.allHeaderFields[key] = value;
                
            } while (0);
            
            if (!self.request)
            {
                self.status = writing;
                self.response = [CGIHTTPResponse HTTP400Response];
                [self sendResponse];
            }
            else
            {
                self.status = readingRequestHeader;
                [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:self.status];
            }
        }
        default:
            break;
    }
}

- (void)processRequest
{
    @try
    {
        self.context = [[CGIHTTPContext alloc] initWithHTTPRequest:self.request queue:self.dispatchQueue];
        if (![self.context matchForVirtualHost])
        {
            self.status = writing;
            self.response = [CGIHTTPResponse HTTP403ResponseWithFile:CGISTR(@"%@://%@%@", self.request.SSL ? @"https" : @"http",
                                                                            self.request.allHeaderFields[@"Host"],
                                                                            self.request.requestPath)];
            [self sendResponse];
            return;
        }
        dbgprintf("ohttpd: info: got request to server %s\n", CGICSTR([self.context.server.listenURL absoluteString]));
        
        [self.context process];
        
        self.response = self.context.response;
        
        if (![self.response.responseBody length])
        {
            self.response.status = nil;
            self.response.statusCode = 204;
        }
        self.status = writing;
        [self sendResponse];
    }
    @catch (NSException *exception)
    {
        self.status = writing;
        self.response = [CGIHTTPResponse HTTP500ResponseWithException:exception];
        [self sendResponse];
    }
}

- (void)stopTimer
{
    if (!self.timer)
        return;
    
    dispatch_source_cancel(self.timer);
    self.timer = nil;
}

- (void)sendResponse
{
    // Post-process the response
    if (![self.response.status length])
        self.response.status = CGIHTTPStatus()[CGISTR(@"%lu", (unsigned long)self.response.statusCode)];
    if (self.response.responseBody)
        self.response.allHeaderFields[@"Content-Length"] = CGISTR(@"%lu", [self.response.responseBody length]);
    NSMutableString *header = [NSMutableString stringWithFormat:@"%@ %lu %@\r\n",
                               self.response.protocolVersion,
                               self.response.statusCode,
                               self.response.status];
    
    for (NSString *key in self.response.allHeaderFields)
    {
        id object = self.response.allHeaderFields[key];
        if ([object isKindOfClass:[NSArray class]])
        {
            for (id value in object)
            {
                [header appendFormat:@"%@: %@\r\n", key, value];
            }
        }
        else
        {
            [header appendFormat:@"%@: %@\r\n", key, object];
        }
    }
    
    [header appendString:@"\r\n"];
    
    NSMutableData *responseData = [NSMutableData dataWithData:[header dataUsingEncoding:NSISOLatin1StringEncoding]];
    [responseData appendData:self.response.responseBody];
    
    [self.socket writeData:responseData withTimeout:-1 tag:self.status];
    
    if (self.response.statusCode == 100)
    {
        self.status = readingRequestBody;
        [self.socket readDataToLength:[self.request.allHeaderFields[@"Content-Length"] integerValue]
                          withTimeout:-1
                                  tag:self.status];
    }
    else if (![self.response.allHeaderFields[@"Connection"] isEqualToString:@"keep-alive"])
    {
        self.request = nil;
        self.response = nil;
        self.context = nil;
        [self.socket disconnectAfterWriting];
    }
    else
    {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dispatchQueue);
        dispatch_source_set_event_handler(self.timer,
                                          ^{
                                              [self stopTimer];
                                              [self.socket disconnectAfterWriting];
                                          });
        NSTimeInterval holdTime = 0;
        if ([self.request.allHeaderFields[@"Keep-Alive"] length])
        {
            holdTime = [self.request.allHeaderFields[@"Keep-Alive"] doubleValue];
        }
        if (holdTime <= 0)
            holdTime = 15;
        
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, holdTime * 1000000000, 0);
        
        self.request = nil;
        self.response = nil;
        self.context = nil;
        
        self.status = readingRequestInit;
        [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:self.status];
    }
}

- (void)run
{
    dbgprintf("ohttpd: info: connected from %s:%u\n",
              CGICSTR(self.socket.connectedHost),
              self.socket.connectedPort);
    
    self.status = readingRequestInit;
    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:self.status];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    dbgprintf("ohttpd: info: disconnected\n");
    [self.listener connectionDidFinish:self];
}

- (void)stop
{
    [self.socket disconnect];
}

@end

#else

#endif
