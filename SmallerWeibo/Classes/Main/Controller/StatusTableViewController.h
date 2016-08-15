//
//  StatusTableViewController.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/12.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusTableViewController : UITableViewController
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,copy)NSArray *dataArr;
@property (nonatomic,copy)void (^reloadDate)(StatusTableViewController *);
@property (nonatomic,copy)void (^loadMoreDate)(StatusTableViewController *);
@end
