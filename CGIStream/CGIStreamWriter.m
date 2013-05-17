//
//  CGIStreamWriter.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIStreamWriter.h"

#define CGIAssignPointer(ptr, val) \
do { typeof(ptr) __ptr = (ptr); \
if (__ptr) *__ptr = (val); \
} while (0)

@implementation CGIStreamWriter
{
    NSOutputStream *_outputStream;
}

- (id)initWithOutputStream:(NSOutputStream *)outputStream
{
    if (self = [super init])
    {
        _outputStream = outputStream;
    }
    return self;
}

- (NSOutputStream *)outputStream
{
    return _outputStream;
}

- (BOOL)write:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError *__autoreleasing *)error
{
    NSData *stringData = [string dataUsingEncoding:encoding];
    NSInteger totalGone = 0;
    
    while ([stringData length] > 0)
    {
        NSInteger gone = [_outputStream write:[stringData bytes] maxLength:[stringData length]];
        
        if (gone < 0)
        {
            // Write failed. Bail out.
            CGIAssignPointer(error, [_outputStream streamError]);
            return NO;
        }
        if (gone == 0)
        {
            // Reached capacity. Stop.
            CGIAssignPointer(error, [NSError errorWithDomain:NSPOSIXErrorDomain
                                                        code:EFBIG
                                                    userInfo:@{@"CGISentBytes": @(totalGone)}]);
            return NO;
        }
        else
        {
            totalGone += gone;
            stringData = [stringData subdataWithRange:NSMakeRange(gone, [stringData length] - gone)];
        }
    }
    
    return YES;
}

@end
