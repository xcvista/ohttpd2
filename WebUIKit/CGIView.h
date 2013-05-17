//
//  CGIView.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGIKit.h>

@interface CGIView : NSObject

@property NSString *text;
@property NSString *identifier;

- (NSString *)HTMLMarkup;

@end
