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
#import "CGIHTTPStatus.h"

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
@property enum CGIConnectionStatus status;
@property NSDate *keepAliveUntil;

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
    
    switch (self.status)
    {
        case readingRequestInit:
        {
            do
            {
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
                
                self.request = request;
            } while (0);
            
            if (!self.response)
            {
                self.status = writing;
                self.response = [CGIHTTPResponse HTTP400Response];
                [self sendResponse];
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
                        self.status = readingRequestBody;
                        [self.socket readDataToLength:[self.request.allHeaderFields[@"Content-Length"] integerValue]
                                          withTimeout:-1
                                                  tag:self.status];
                    }
                    else
                    {
                        self.status = processing;
                        [self processRequest];
                    }
                }
                
                NSRange colon = [line rangeOfString:@":"];
                if ()
            } while (0);
            
            if (!self.request)
            {
                self.status = writing;
                self.response = [CGIHTTPResponse HTTP400Response];
                [self sendResponse];
            }
        }
        default:
            break;
    }
}

- (void)processRequest
{
    
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
        [header appendFormat:@"%@: %@\r\n", key, self.response.allHeaderFields[key]];
    }
    
    [header appendString:@"\r\n"];
    
    NSMutableData *responseData = [NSMutableData dataWithData:[header dataUsingEncoding:NSISOLatin1StringEncoding]];
    [responseData appendData:self.response.responseBody];
    
    [self.socket writeData:responseData withTimeout:-1 tag:self.status];
    
    if (![self.response.allHeaderFields[@"Connection"] isEqualToString:@"keep-alive"])
    {
        [self.socket disconnectAfterWriting];
    }
    else
    {
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
