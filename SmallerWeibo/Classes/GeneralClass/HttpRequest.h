//
//  HttpRequest.h
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^success)(id object);
typedef void (^failure)(NSError *error);
@interface HttpRequest : NSObject
+ (void)httpRequestWithUrl:(NSString *)url parameter:(NSDictionary *)dict success:(success)success failure:(failure)failure isGET:(BOOL)isget type:(NSString *)type;
+ (void)statusHttpRequestWithType:(NSInteger)type page:(NSInteger)page success:(success)success failure:(failure)failure;
+ (void)likeStatusHttpRequestWithStatusId:(NSString *)statusId type:(NSInteger)type success:(success)sucess failure:(failure)faliure;
+ (void)detailsStatusHttpRequestWithStatusID:(NSString *)statusId page:(NSInteger)page success:(success)success failure:(failure)failure;
+ (void)friendsHttpRequestWithSuccess:(success)success failure:(failure)failure cursor:(NSInteger)cursor type:(NSInteger)type userID:(NSString *)uid;
+ (void)userShowHttpRequestWithId:(NSString *)name page:(NSInteger)page success:(success)success failure:(failure)failure;
+ (void)userModelFromUserName:(NSString *)name success:(success)success failure:(failure)failure;
+ (void)topicStatusWithTopic:(NSString *)topic page:(NSInteger)page success:(success)success failure:(failure)failure;
+ (void)shortUrlWithurl:(NSString *)shortUrl success:(success)success failure:(failure)failure;
+ (void)newStatusWithStatusText:(NSString *)status success:(success)success failure:(failure)failure;
+ (void)uploadImgWithData:(NSData *)img success:(success)success failurl:(failure)failure;
+ (void)sendStatusWithStatus:(NSString *)status picID:(NSArray *)picID success:(success)success failure:(failure)failure;
+ (void)searchForUserWithText:(NSString *)text page:(NSInteger)page success:(success)success failure:(failure)failure;
+ (void)userInfoWithToken:(NSString *)token userID:(NSString *)uid success:(success)success failure:(failure)failure;
+ (void)repateAndCommentsWithstatusId:(NSString *)statusId status:(NSString *)status success:(success)success failure:(failure)failure isComment:(BOOL)isComment;
+ (void)followUserWithUserId:(NSString *)uid isFollowed:(BOOL)isFollowed success:(success)success failure:(failure)failure;
@end
