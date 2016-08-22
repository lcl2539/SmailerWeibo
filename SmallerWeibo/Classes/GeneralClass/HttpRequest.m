//
//  HttpRequest.m
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "HttpRequest.h"
#import "AFNetworking.h"
#import "PrefixHeader.pch"
@interface HttpRequest ()

@end

@implementation HttpRequest
+ (void)httpRequestWithUrl:(NSString *)url parameter:(NSDictionary *)dict success:(void (^)(id object))success failure:(void (^)(NSError *error))failure isGET:(BOOL)isget type:(NSString *)type{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:type, nil];
    static NSDictionary *baseDict;
    baseDict = @{@"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]};
    NSMutableDictionary *para = [baseDict mutableCopy];
    [para setValuesForKeysWithDictionary:dict];
    if (isget) {
        [manager GET:url parameters:para progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    }else{
        [manager POST:url parameters:para progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    }
}

+ (void)statusHttpRequestWithType:(NSInteger)type page:(NSInteger)page success:(void (^) (id Object))success failure:(void (^) (NSError *error))failure{
    static NSArray *urlArr;
    urlArr = @[@"https://api.weibo.com/2/statuses/home_timeline.json",//我的微博主页
               @"https://api.weibo.com/2/statuses/user_timeline.json",//我发表的微博
               @"https://api.weibo.com/2/statuses/public_timeline.json",//公共微博
               @"https://api.weibo.com/2/favorites.json",//收藏
               @"https://api.weibo.com/2/comments/by_me.json",//我的评论
               @"https://api.weibo.com/2/comments/mentions.json",//@我的评论
               @"https://api.weibo.com/2/statuses/mentions.json",//@我的微博
               ];
    NSDictionary *dict = @{@"page":[NSNumber numberWithInteger:page],
                           @"count":@20};
    [self httpRequestWithUrl:urlArr[type] parameter:dict success:^(id object) {
        success(object);
    } failure:^(NSError *error) {
        
    } isGET:YES type:type_json];
}

+ (void)searchHttpRequestWithKey:(NSString *)key page:(NSInteger)page success:(void (^) (id object))sucess failure:(void (^) (NSError *error))faliure{
    
}

+ (void)likeStatusHttpRequestWithStatusId:(NSInteger)statusId success:(void (^) (id object))sucess failure:(void (^) (NSError *error))faliure{
    static NSString *baseURL;
    baseURL = @"https://api.weibo.com/2/favorites/create.json";
    NSDictionary *dict = @{@"id":[NSNumber numberWithInteger:statusId]};
    [self httpRequestWithUrl:baseURL parameter:dict success:^(id object) {
        sucess(object);
    } failure:^(NSError *error) {
        faliure(error);
    } isGET:NO type:type_json];
}

@end
