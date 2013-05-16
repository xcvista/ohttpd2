//
//  CGIHandler.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@class CGIHTTPContext;

@protocol CGIHandler <NSObject>

@required
- (BOOL)canReuse;
- (void)handle:(CGIHTTPContext *)context;

@end
