//
//  NSInputStream+CGIStreamReader.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInputStream (CGIStreamReader)

- (NSData *)forceReadLength:(NSUInteger)length;

@end
