//
//  MineEditTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDEditTextField.h"

typedef enum : NSUInteger {
    EditMineType_Name,
    EditMineType_Sex,
    EditMineType_Detail,
    EditMineType_TelNumber,
    EditMineType_Birthday,
    EditMineType_Address,
    EditMineType_EMail
} EditMineType;

@interface MineEditTableViewCell : UITableViewCell

@property (nonatomic, strong) DDEditTextField * textField;

- (void)configWithType:(EditMineType)type indexPath:(NSIndexPath *)indexPath;

@end
