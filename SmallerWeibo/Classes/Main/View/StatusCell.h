//
//  StatusCell.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface StatusBtn : UIButton

@end
typedef enum : NSUInteger {
    kBtnLikeType,
    kBtnRepeatType,
    kBtnCommentType,
    kBtnSupportType
} BtnType;
@interface StatusCell : UITableViewCell
@property (nonatomic,strong)id model;
@property (nonatomic,copy) void (^btnDidClick)(StatusCell *,BtnType);
- (void)changeBtnStatuWithType:(BtnType)type;
- (void)imageWithLocotion:(CGPoint)point result:(void (^)(CGRect frame,NSString *url))result;
+ (instancetype)statusCellWithTableView:(UITableView *)tableView;
@end
