//
//  CGIVirtualHost.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIVirtualHost.h"

@implementation CGIVirtualHost

- (id)initWithListenURL:(NSURL *)URL
{
    if (self = [super init])
    {
        self.listenURL = URL;
    }
    return self;
}

@end
