//
//  CGIConnection.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@class CGIListener;

#ifndef GNUSTEP

#import <GCDAsyncSocket/GCDAsyncSocket.h>

@interface CGIConnection : NSObject

@property GCDAsyncSocket *socket;
@property dispatch_queue_t dispatchQueue; // DO NOT use dispatch_get_main_queue!
@property (weak) CGIListener *listener;

- (id)initWithSocket:(GCDAsyncSocket *)socket listener:(CGIListener *)listener;
- (void)run;
- (void)stop;

@end

#else

@interface CGIConnection : NSObject

@property NSInputStream *input;
@property NSOutputStream *output;
@property dispatch_queue_t dispatchQueue; // DO NOT use dispatch_get_main_queue!
@property NSDictionary *connectionInfo;

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
- (void)run;

@end

#endif