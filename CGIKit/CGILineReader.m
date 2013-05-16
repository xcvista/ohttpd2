//
//  CGILineReader.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGILineReader.h"

@implementation CGILineReader
{
    FILE *fd;
}

- (id)initWithFile:(NSString *)fileName error:(NSError *__autoreleasing *)error
{
    if (self = [super init])
    {
        fd = fopen(CGICSTR(fileName), "r");
        if (!fd)
        {
            NSError *err = [NSError errorWithDomain:NSPOSIXErrorDomain
                                               code:errno
                                           userInfo:nil];
            CGIAssignPointer(error, err);
            return nil;
        }
    }
    return self;
}

- (NSString *)readLine
{
    if (!feof(fd))
    {
        size_t size = BUFSIZ;
        ssize_t length = 0;
        char *buf = malloc(size);
        
        if (!buf)
            return nil;
        
        memset(buf, 0, size);
        
        length = getline(&buf, &size, fd);
        
        if (length < 0)
            return nil;
        
        NSData *data = [NSData dataWithBytesNoCopy:buf
                                            length:size
                                      freeWhenDone:YES];
        return [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, length)]
                                     encoding:NSUTF8StringEncoding];
    }
    else
        return nil;
}

- (BOOL)endOfFile
{
    return (feof(fd)) ? YES : NO;
}

@end
