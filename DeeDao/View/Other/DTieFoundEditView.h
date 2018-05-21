//
//  DTieFoundEditView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@class DTieFoundEditView;
@protocol DTieFoundEditViewDelegate <NSObject>

- (void)DTieFoundEditViewBeginEidt:(DTieFoundEditView *)view;

@end

@interface DTieFoundEditView : UIView

@property (nonatomic, weak) id<DTieFoundEditViewDelegate> delegate;

@property (nonatomic, strong) UITextField * titleTextField;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UILabel * locationLabel;

- (instancetype)initWithFrame:(CGRect)frame coordinate:(CLLocationCoordinate2D)coordinate;

@end
