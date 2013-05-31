//
//  CGIStaticFileHandler.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-6-1.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIStaticFileHandler.h"
#import "CGIHTTPContext.h"
#import "CGIHTTPRequest.h"
#import "CGIHTTPResponse.h"
#import "CGIVirtualHost.h"

@implementation CGIStaticFileHandler

+ (void)handle:(CGIHTTPContext *)context
{
    NSString *path = [context.request.requestPath stringByStandardizingPath];
    NSString *targetPath = [context.server.documentRoot stringByAppendingPathComponent:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:targetPath isDirectory:&isDir];
    
    if (!isExist)
    {
        
    }
}

@end
