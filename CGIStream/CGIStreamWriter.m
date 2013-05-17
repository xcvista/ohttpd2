//
//  CGIStreamWriter.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIStreamWriter.h"
#import "NSOutputStream+CGIStreamWriter.h"

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
    NSInteger gone = [_outputStream forceWriteData:stringData];
    
    if (gone < 0)
    {
        CGIAssignPointer(error, [_outputStream streamError]);
        return NO;
    }
    else if (gone < [stringData length])
    {
        CGIAssignPointer(error, [NSError errorWithDomain:NSPOSIXErrorDomain
                                                    code:EFBIG
                                                userInfo:@{@"CGIBytesSent": @(gone)}]);
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
