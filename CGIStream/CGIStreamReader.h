//
//  CGIStreamReader.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGIStreamReader : NSObject

- (id)initWithInputStream:(NSInputStream *)inputStream;
- (id)initWithFile:(NSString *)fileName error:(NSError **)error;

- (NSInputStream *)inputStream;
- (NSString *)readUntilCharacter:(NSData *)deliminator encoding:(NSStringEncoding)encoding;
- (NSString *)readLine;
- (NSArray *)shellReadLine;
- (BOOL)endOfFile;

+ (NSData *)newLine;
+ (NSData *)crLf;

@end
