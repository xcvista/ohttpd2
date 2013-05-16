//
//  CGIListener.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIListener.h"

@implementation CGIListener

- (id)initWithPort:(uint16_t)port
{
    if (self = [super init])
    {
        self.port = port;
    }
    return self;
}

- (BOOL)bindWithError:(NSError *__autoreleasing *)error
{
    
}

- (BOOL)unbindWithError:(NSError *__autoreleasing *)error
{
    
}

- (void)dealloc
{
    if (self.binded)
        [self unbindWithError:NULL];
}

@end
