//
//  QYStatusModel.h
//  青云微博
//
//  Created by qingyun on 16/7/14.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel;

@interface StatusModel : NSObject

/** created_at	string	微博创建时间 */
@property (nonatomic, copy) NSString *strCreatedAt;

/** idstr	string	字符串型的微博ID */
@property (nonatomic, copy) NSString *strIdstr;

/** text	string	微博信息内容 */
@property (nonatomic, copy) NSString *strText;

/** source	string	微博来源 */
@property (nonatomic, copy) NSString *strSource;
@property (nonatomic, copy, readonly) NSString *strSourceDes;

/** favorited	boolean	是否已收藏，true：是，false：否 */
@property (nonatomic, assign, getter = isFavorited) BOOL favorited;

/** user	object	微博作者的用户信息字段 详细 */
@property (nonatomic, strong) UserModel *user;

/** retweeted_status	object	被转发的原微博信息字段，当该微博为转发微博时返回 详细 */
@property (nonatomic, strong) StatusModel *retweetedStatus;

/** reposts_count	int	转发数 */
@property (nonatomic, assign) NSInteger repostsCount;

/** comments_count	int	评论数 */
@property (nonatomic, assign) NSInteger commentsCount;

/** attitudes_count	int	表态数 */
@property (nonatomic, assign) NSInteger attitudesCount;

/** pic_urls array 微博图片 */
@property (nonatomic, copy) NSArray *arrPicUrls;

/** QYStatusModel模型初始化方法 */
+ (instancetype)statusModelWithDictionary:(NSDictionary *)dicData;

@end
