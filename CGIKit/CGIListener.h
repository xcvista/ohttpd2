//
//  CGIListener.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@class CGIConnection;

@interface CGIListener : NSObject

@property uint16_t port;
@property (readonly) BOOL binded;
@property NSMutableArray *connections;

- (id)initWithPort:(uint16_t)port;

- (BOOL)bindWithError:(NSError **)error;
- (BOOL)unbindWithError:(NSError **)error;

- (void)connectionDidFinish:(CGIConnection *)connection;

@end
