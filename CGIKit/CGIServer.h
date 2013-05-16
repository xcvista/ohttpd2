//
//  CGIServer.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

CGIExtern NSString *CGIServerReloadNotification;
CGIExtern NSString *CGIServerStopNotification;
CGIExtern NSString *CGIServerWillStopNotification;

@interface CGIServer : NSObject

@property NSString *configFilePath;
@property NSString *instanceIdentifier;

+ (instancetype)server;

- (void)start __attribute((noreturn));
- (void)stop;
- (void)reload;

@end
