//
//  HttpRequest.h
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^success)(id object);
typedef void (^failure)(NSError *error);
@interface HttpRequest : NSObject
+ (void)httpRequestWithUrl:(NSString *)url parameter:(NSDictionary *)dict success:(success)success failure:(failure)failure isGET:(BOOL)isget type:(NSString *)type;
+ (void)statusHttpRequestWithType:(NSInteger)type page:(NSInteger)page success:(success)success failure:(failure)failure;
+ (void)searchHttpRequestWithKey:(NSString *)key page:(NSInteger)page success:(success)sucess failure:(failure)faliure;
+ (void)likeStatusHttpRequestWithStatusId:(NSInteger)statusId type:(NSInteger)type success:(success)sucess failure:(failure)faliure;
+ (void)detailsStatusHttpRequestWithStatusID:(NSString *)statusId page:(NSInteger)page success:(success)success failure:(failure)failure;
+ (void)userInfoHttpRequestWithSuccess:(success)success failure:(failure)faliure;
+ (void)fansHttpRequestWithSuccess:(success)success failure:(failure)failure cursor:(NSInteger)cursor;
+ (void)userShowHttpRequestWithName:(NSString *)name page:(NSInteger)page success:(success)success failure:(failure)failure;
@end
