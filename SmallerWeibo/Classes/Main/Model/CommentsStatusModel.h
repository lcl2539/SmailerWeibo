//
//  CommentsStatusModel.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/22.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserModel;
@class StatusModel;
@interface CommentsStatusModel : NSObject
@property (nonatomic,assign)NSInteger commentID;
/** created_at	string	微博创建时间 */
@property (nonatomic, copy) NSString *strCreatedAt;
/** idstr	string	评论文字 */
@property (nonatomic, copy) NSString *commentText;
@property (nonatomic, strong) UserModel *user;
@property (nonatomic,copy)NSString *strSource;
@property (nonatomic,strong)StatusModel *status;
+ (instancetype)commentsModelWithDictionary:(NSDictionary *)dicData;
@end
