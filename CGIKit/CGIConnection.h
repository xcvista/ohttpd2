//
//  CGIConnection.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@interface CGIConnection : NSObject

@property NSInputStream *input;
@property NSOutputStream *output;
@property dispatch_queue_t dispatchQueue; // DO not use dispatch_get_main_queue!
@property NSDictionary *connectionInfo;

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
- (void)run;

@end
