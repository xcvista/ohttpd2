//
//  CGIHTTPRequest.h
//  ohttpd2
//
//  Created by Maxthon Chan on 13-5-17.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGICommon.h>

@interface CGIHTTPRequest : NSObject

@property NSDictionary *allHeaderFields;
@property NSString *method;
@property NSString *requestPath;
@property NSString *protocolVersion;
@property NSData *requestBody;

- (NSDictionary *)query;
- (NSDictionary *)form;
- (NSDictionary *)acceptMIME;
- (NSDictionary *)acceptLanguage;
- (NSDictionary *)acceptStringEncoding;
- (NSDictionary *)cookie;

@end
