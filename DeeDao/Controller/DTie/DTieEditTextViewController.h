//
//  DTieEditTextViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@protocol DTEditTextViewControllerDelegate <NSObject>

- (void)DTEditTextDidFinished:(NSString *)text;

@end

@interface DTieEditTextViewController : DDViewController

@property (nonatomic, assign) id<DTEditTextViewControllerDelegate> delegate;

- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder;

@end
