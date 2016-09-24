//
//  LStatusTableVC.h
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/20.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LStatusTableVC : UITableViewController
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,copy)NSArray *dataArr;
@property (nonatomic,copy)void (^reloadDate)(LStatusTableVC *,BOOL);
@property (nonatomic,copy)void (^didScroll)();
@property (nonatomic,copy)void (^changeTop)(NSInteger,NSInteger);
@property (nonatomic,assign)BOOL haveReload;
@end
