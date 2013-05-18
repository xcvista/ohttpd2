//
//  CGIFileStreamReader.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-18.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGIFileStreamReader : NSObject

- (id)initWithFile:(NSString *)fileName error:(NSError **)error;

- (NSString *)readUntilCharacter:(char)deliminator encoding:(NSStringEncoding)encoding;
- (NSString *)readLine;
- (NSArray *)shellReadLine;
- (BOOL)endOfFile;

@end
