//
//  HttpRequest.h
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequest : NSObject
+ (void)httpRequestWithUrl:(NSString *)url parameter:(NSDictionary *)dict success:(void (^)(id object))success failure:(void (^)(NSError *error))failure isGET:(BOOL)isget type:(NSString *)type;
+ (void)statusHttpRequestWithType:(NSInteger)type page:(NSInteger)page success:(void (^) (id Object))success failure:(void (^) (NSError *error))failure;
@end
