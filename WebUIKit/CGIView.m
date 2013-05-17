//
//  CGIView.m
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import "CGIView.h"

@implementation CGIView

- (NSString *)HTMLMarkup
{
    return CGISTR(@"<div id=\"%@\">%@</div>", self.text, self.identifier);
}

@end
