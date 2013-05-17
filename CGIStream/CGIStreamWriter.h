//
//  CGIStreamWriter.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGIStreamWriter : NSObject

- (id)initWithOutputStream:(NSOutputStream *)outputStream;

- (NSOutputStream *)outputStream;
- (BOOL)write:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError **)error;

@end
