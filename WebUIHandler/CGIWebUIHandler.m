//
//  CGIWebUIHandler.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIWebUIHandler.h"
#import <WebUIKit/WebUIKit.h>

@implementation CGIWebUIHandler

- (BOOL)canReuse
{
    return YES;
}

- (void)handle:(CGIHTTPContext *)context
{
    
}

@end
