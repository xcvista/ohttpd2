//
//  CGILineReader.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@interface CGILineReader : NSObject

- (id)initWithFile:(NSString *)fileName error:(NSError **)error;

- (NSString *)readLine;
- (NSArray *)shellReadLine;
- (BOOL)endOfFile;

@end
