//
//  NSInputStream+CGIStreamReader.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "NSInputStream+CGIStreamReader.h"

@implementation NSInputStream (CGIStreamReader)

- (NSData *)forceReadLength:(NSUInteger)length
{
    NSMutableData *outputData = [NSMutableData dataWithCapacity:length];
    
    uint8_t *buffer = malloc(length);
    if (!buffer)
        return nil;
    
    while ([outputData length] < length)
    {
        NSInteger got = [self read:buffer maxLength:length - [outputData length]];
        if (got < 0)
        {
            return nil;
        }
        else if (got == 0)
        {
            break;
        }
        else
        {
            
        }
    }
}

@end
