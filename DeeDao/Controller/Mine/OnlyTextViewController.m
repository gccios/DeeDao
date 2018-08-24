//
//  OnlyTextViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "OnlyTextViewController.h"

@interface OnlyTextViewController ()

@property (nonatomic, copy) NSString * text;

@end

@implementation OnlyTextViewController

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super init]) {
        self.text = text;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, kMainBoundsWidth - 40, kMainBoundsHeight - 20)];
    [self.view addSubview:textView];
    textView.text = self.text;
    textView.editable = NO;
    textView.font = kPingFangRegular(20);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfDidClicked)];
    [textView addGestureRecognizer:tap];
}

- (void)selfDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
