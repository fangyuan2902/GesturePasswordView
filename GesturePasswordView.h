//
//  GesturePasswordView.h
//  ProjectDemo
//
//  Created by 远方 on 2017/3/3.
//  Copyright © 2017年 远方. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GesturePasswordButton : UIView

//选中
@property (nonatomic,assign) BOOL selected;
//正确
@property (nonatomic,assign) BOOL success;

@end

@protocol ResetVerificationDelegate <NSObject>

@optional
/**
 验证结果

 @param result 密码字符串
 @return return value description
 */
- (BOOL)verification:(NSString *)result;

/**
 重置

 @param result 密码字符串
 @return return value description
 */
- (BOOL)resetPassword:(NSString *)result;

@end

@interface NiceCircleView : UIView

DEFINE_PROPERTY_STRONG(NSArray *, buttonArray)
DEFINE_PROPERTY_ASSIGN(id<ResetVerificationDelegate>, delegate)

//style 1: 验证 2: 重置
DEFINE_PROPERTY_ASSIGN(NSInteger, style)

/**
 重新绘制
 */
- (void)enterArgin;

@end

@interface GesturePasswordView : UIView

//9个点
DEFINE_PROPERTY_STRONG(NiceCircleView *, circleView)

@end
