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
+ (void)httpRequestWithUrl:(NSString *)url parameter:(NSDictionary *)dict success:(success)success failure:(failure)failure isGET:(BOOL)isget type:(NSString *)type{
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

+ (void)statusHttpRequestWithType:(NSInteger)type page:(NSInteger)page success:(success)success failure:(failure)failure{
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
        failure(error);
    } isGET:YES type:type_json];
}

+ (void)searchHttpRequestWithKey:(NSString *)key page:(NSInteger)page success:(success)sucess failure:(failure)faliure{
    
}

+ (void)detailsStatusHttpRequestWithStatusID:(NSString *)statusId page:(NSInteger)page success:(success)success failure:(failure)failure{
    static NSString *url;
    url = @"https://api.weibo.com/2/comments/show.json";
    NSDictionary *dict = @{@"id":statusId,
                           @"count":@30,
                           @"page":[NSNumber numberWithInteger:page]
                           };
    [self httpRequestWithUrl:url parameter:dict success:^(id object) {
        success(object);
    } failure:^(NSError *error) {
        failure(error);
    } isGET:YES type:type_json];
}

+ (void)likeStatusHttpRequestWithStatusId:(NSInteger)statusId type:(NSInteger)type success:(success)sucess failure:(failure)faliure{
    static NSArray *urlArr;
    urlArr = @[@"https://api.weibo.com/2/favorites/create.json",//收藏
               @"https://api.weibo.com/2/statuses/repost.json"//转发
               ];
    NSDictionary *dict = @{@"id":[NSNumber numberWithInteger:statusId]};
    [self httpRequestWithUrl:urlArr[type - 1] parameter:dict success:^(id object) {
        sucess(object);
    } failure:^(NSError *error) {
        faliure(error);
    } isGET:NO type:type_json];
}

+ (void)userInfoHttpRequestWithSuccess:(success)success failure:(failure)faliure{
    static NSString *url;
    url = @"https://api.weibo.com/2/users/show.json";
    NSDictionary *dict = @{@"uid":userId};
    [self httpRequestWithUrl:url parameter:dict success:^(id object) {
        success(object);
    } failure:^(NSError *error) {
        faliure(error);
    } isGET:YES type:type_json];
}

+ (void)fansHttpRequestWithSuccess:(success)success failure:(failure)failure cursor:(NSInteger)cursor{
    static NSString *url;
    url = @"https://api.weibo.com/2/friendships/followers.json";
    NSDictionary *dict = @{@"uid":userId,
                           @"count":@20,
                           @"cursor":[NSNumber numberWithInteger:cursor]};
    [self httpRequestWithUrl:url parameter:dict success:^(id object) {
        success(object);
    } failure:^(NSError *error) {
        failure(error);
    } isGET:YES type:type_json];
}
@end
