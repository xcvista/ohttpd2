//
//  CGIStreamReader.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIStreamReader.h"

#define eprintf(format, ...) fprintf(stderr, format, ##__VA_ARGS__)
#define CGIAssignPointer(ptr, val) \
do { typeof(ptr) __ptr = (ptr); \
if (__ptr) *__ptr = (val); \
} while (0)

@implementation CGIStreamReader
{
    NSInputStream *_inputStream;
    char *_buffer;
    char *_pLast;
    char *_pCurrent;
}

- (id)initWithFile:(NSString *)fileName error:(NSError *__autoreleasing *)error
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:fileName];
    if (!inputStream)
    {
        CGIAssignPointer(error, [NSError errorWithDomain:NSPOSIXErrorDomain
                                                    code:ENOENT
                                                userInfo:nil]);
        return nil;
    }
    else
        return [self initWithInputStream:inputStream];
}

- (id)initWithInputStream:(NSInputStream *)inputStream
{
    if (self = [super init])
    {
        _inputStream = inputStream;
        _buffer = malloc(BUFSIZ);
        
        if (!_buffer)
            return nil;
        
        _pLast = _buffer;
        _pCurrent = _buffer;
    }
    return self;
}

- (NSInputStream *)inputStream
{
    return _inputStream;
}

- (NSString *)readLine
{
    return [self readUntilCharacter:'\n' encoding:NSUTF8StringEncoding]; // This works for both Windows and UNIX.
}

- (NSString *)readUntilCharacter:(char)deliminator encoding:(NSStringEncoding)encoding
{
    NSMutableData *pickedUp = [NSMutableData data];
    
    if (_pCurrent >= _pLast)
    {
        // Buffer is drained, fill it.
        
    }
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
