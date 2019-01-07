//
//  DDGroupCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/3.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDGroupCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) void (^groupDidChooseHandle)(void);

@end
