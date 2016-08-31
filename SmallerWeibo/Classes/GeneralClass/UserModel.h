//
//  QYUserModel.h
//  青云微博
//
//  Created by qingyun on 16/7/14.
//  Copyright © 2016年 qingyun. All rights reserved.
//

// JSON, XML

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

/** idstr	string	字符串型的用户UserId */
@property (nonatomic, copy) NSString *strIdstr;

/** screen_name	string	用户昵称, NickName */
@property (nonatomic, copy) NSString *strScreenName;

/** name	string	友好显示名称 */
@property (nonatomic, copy) NSString *strName;

/** description	string	用户个人描述 */
@property (nonatomic, copy) NSString *strUserDescription;

/** profile_image_url	string	用户头像地址（中图），50×50像素 */
@property (nonatomic, copy) NSString *strProfileImageUrl;

/** followers_count	int	粉丝数 */
@property (nonatomic, assign) NSInteger followersCount;

/** friends_count	int	关注数 */
@property (nonatomic, assign) NSInteger friendsCount;

/** statuses_count	int	微博数 */
@property (nonatomic, assign) NSInteger statusesCount;

/** favourites_count	int	收藏数 */
@property (nonatomic, assign) NSInteger favourites_count;

/** avatar_large	string	用户头像地址（大图），180×180像素 */
@property (nonatomic, copy) NSString *strAvatarLarge;

/** avatar_hd	string	用户头像地址（高清），高清头像原图 */
@property (nonatomic, copy) NSString *strAvatarHd;
/**是否关注*/
@property (nonatomic,assign)BOOL following;
/**是否关注我*/
@property (nonatomic,assign)BOOL followMe;
/** 模型的初始化方法 */
+ (instancetype)userModelWithDictionary:(NSDictionary *)dicData;
+ (instancetype)CreatMyModle:(NSDictionary *)dict;
@end
