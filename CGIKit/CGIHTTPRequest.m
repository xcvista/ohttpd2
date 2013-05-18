//
//  CGIHTTPRequest.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIHTTPRequest.h"

@implementation CGIHTTPRequest

- (id)init
{
    self = [super init];
    if (self) {
        self.allHeaderFields = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
