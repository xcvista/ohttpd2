//
//  NSOutputStream+CGIStreamWriter.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "NSOutputStream+CGIStreamWriter.h"

@implementation NSOutputStream (CGIStreamWriter)

- (NSInteger)forceWriteData:(NSData *)data
{
    NSInteger totalGone = 0;
    
    while ([data length] > 0)
    {
        NSInteger gone = [self write:[data bytes] maxLength:[data length]];
        
        if (gone < 0)
        {
            // Write failed. Bail out.
            return -1;
        }
        if (gone == 0)
        {
            break;
        }
        else
        {
            totalGone += gone;
            data = [data subdataWithRange:NSMakeRange(gone, [data length] - gone)];
        }
    }
    
    return totalGone;
}

@end
