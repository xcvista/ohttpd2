//
//  CGIHTTPResponse.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@interface CGIHTTPResponse : NSObject

@property NSMutableDictionary *allHeaderFields;
@property NSUInteger statusCode;
@property NSString *protocolVersion;
@property NSData *responseBody;

- (void)redirect:(NSString *)target;
- (void)proxy:(NSString *)target;

@end
