

#import <UIKit/UIKit.h>

@protocol DatePickerViewDelegate <NSObject>
@optional
/**
 * 确定按钮
 */
-(void)didClickFinishDateTimePickerView:(NSString*)date;
/**
 * 取消按钮
 */
-(void)didClickCancelDateTimePickerView;

@end


@interface DatePickerView : UIView

/**
 * 设置当前时间
 */
@property(nonatomic, strong)NSDate*currentDate;

@property(nonatomic, assign) NSInteger currentTime;
/**
 * 设置中心标题文字
 */
@property(nonatomic, strong)UILabel *titleL;

@property(nonatomic, strong)id<DatePickerViewDelegate>delegate;

/**
 * 隐藏
 */
- (void)hideDateTimePickerView;

/**
 * 显示
 */
- (void)showDateTimePickerView;

- (void)showDateTimePickerViewWithDate:(NSDate *)date;

@end
