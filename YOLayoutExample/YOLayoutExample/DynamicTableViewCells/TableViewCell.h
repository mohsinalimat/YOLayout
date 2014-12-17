//
//  TableViewCell.h
//  YOLayoutExample
//
//  Created by John Boiles on 12/16/14.
//  Copyright (c) 2014 YOLayout. All rights reserved.
//

#import "YOView.h"

@interface TableViewCellView : YOView

@end

@interface TableViewCell : UITableViewCell
@property (strong, nonatomic) TableViewCellView *view;
@property (strong ,nonatomic) NSString *string;
@end