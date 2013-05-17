//
//  CGISocket.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@interface CGISocket : NSObject

- (id)initWithProtocolFamily:(int)family error:(NSError **)error;
- (BOOL)bindSocketToPort:(uint16_t)port error:(NSError **)error;
- (BOOL)unbindSocketWithError:(NSError **)error;


@end
