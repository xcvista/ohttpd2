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

- (NSArray *)shellReadLine
{
    NSString *line = [self readLine];
    
    if (!line)
        return nil;
    
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    
    NSCharacterSet *quotes = [NSCharacterSet characterSetWithCharactersInString:@"\'\""];
    NSCharacterSet *hashes = [NSCharacterSet characterSetWithCharactersInString:@"#"];
    
    NSMutableArray *outputBuffer = [NSMutableArray array];
    NSMutableString *buffer = [NSMutableString string];
    NSMutableString *tmpBuffer = [NSMutableString string];
    
    unichar quote = 0;
    
    NSUInteger status = 0; // 0 = start
                           // 1 = mid-symbol
                           // 2 = start-escape
                           // 3 = in-quote
                           // 4 = dollar...
                           // 5 = dollar-parenthesis (insert environment variable)
    
start:
    for (NSUInteger i = 0; i < [line length]; i++)
    {
        unichar ch = [line characterAtIndex:i];
        switch (status)
        {
            case 0:
            case 1:
            {
                if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch])
                {
                    if (status == 0)
                        continue;
                    else
                    {
                        if ([buffer length])
                            [outputBuffer addObject:[buffer copy]];
                        [buffer setString:@""];
                        status = 0;
                    }
                }
                else if ([hashes characterIsMember:ch])
                    goto done; // okay stop processing.
                else if ([quotes characterIsMember:ch])
                { // open quote
                    quote = ch;
                    status = 3;
                }
                else if (ch == '$')
                    status = 4; // dollar
                else if (ch == '\\')
                    status = 2; // escape
                else
                {
                    [buffer appendFormat:@"%C", ch];
                    status = 1;
                }
                break;
            }
            case 2:
            {
                switch (ch)
                {
                    case 'n':
                        ch = '\n';
                        break;
                    case 't':
                        ch = '\t';
                        break;
                }
                [buffer appendFormat:@"%C", ch];
                status = 1;
                break;
            }
            case 3:
            {
                if (ch == quote)
                {
                    status = 1;
                    quote = 0;
                }
                else
                {
                    [buffer appendFormat:@"%C", ch];
                    status = 3;
                }
                break;
            }
            case 4:
            {
                if (ch == '(')
                    status = 5;
                else
                {
                    [buffer appendFormat:@"%C", ch];
                    status = 1;
                }
                break;
            }
            case 5:
            {
                if (ch == ')')
                {
                    [buffer appendString:environment[[tmpBuffer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
                    [tmpBuffer setString:@""];
                    status = 1;
                }
                else
                    [tmpBuffer appendFormat:@"%C", ch];
            }
            default:
                break;
        }
    }
    
    switch (status)
    {
        case 0:
        case 1:
            if ([buffer length])
                [outputBuffer addObject:[buffer copy]];
            break;
        default:
            line = [self readLine];
            if (!line)
            {
                eprintf("ohttpd: error: cannot parse config file.");
                return nil;
            }
            goto start;
            break;
    }
    
done:
    return [outputBuffer copy];
}

@end
