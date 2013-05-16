//
//  CGICommon.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#include "CGICommon.h"

NSString *CGIStringFromBufferedAction(NSUInteger size,
                                      NSStringEncoding encoding,
                                      void (^action)(char *buffer, NSUInteger size))
{
    if (size == 0)
        size = BUFSIZ;
    
    char *buffer = malloc(size);
    if (!buffer)
        return nil;
    
    action(buffer, size);
    
    return [NSString stringWithCString:buffer
                              encoding:encoding];
}