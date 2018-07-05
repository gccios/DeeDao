//
//  DTieCreateLocationView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTieCreateLocationViewDelegate <NSObject>

- (void)DTieCreateLocationDidCancle;
- (void)DTieCreateLocationDidCompleteAddress:(NSString *)address name:(NSString *)name introduce:(NSString *)introduce;

@end

@interface DTieCreateLocationView : UIView

@property (nonatomic, weak) id<DTieCreateLocationViewDelegate> delegate;

- (void)configAddress:(NSString *)address;

- (void)endEdit;

@end
