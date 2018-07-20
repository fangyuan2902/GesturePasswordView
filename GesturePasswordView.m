//
//  GesturePasswordView.m
//  ProjectDemo
//
//  Created by 远方 on 2017/3/3.
//  Copyright © 2017年 远方. All rights reserved.
//

#import "GesturePasswordView.h"

@implementation GesturePasswordButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _success = YES;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (_selected) {
        if (_success) {
            CGContextSetRGBStrokeColor(context,61.0/255.f, 119.0/255.f, 238.0/255.f,1);
            CGContextSetRGBFillColor(context,61.0/255.f, 119.0/255.f, 238.0/255.f,1);
        } else {
            CGContextSetRGBStrokeColor(context,208/255.f, 36/255.f, 36/255.f,1);
            CGContextSetRGBFillColor(context,208/255.f, 36/255.f, 36/255.f,1);
        }
        
        CGRect frame = CGRectMake(self.bounds.size.width / 2 - self.bounds.size.width / 8 + 1, self.bounds.size.height / 2 - self.bounds.size.height / 8, self.bounds.size.width / 4, self.bounds.size.height / 4);
        
        CGContextAddEllipseInRect(context,frame);
        CGContextFillPath(context);
    } else {
        CGContextSetRGBStrokeColor(context,166.0/255.f, 166.0/255.f, 166.0/255.f,1);//线条颜色
    }
    
    CGContextSetLineWidth(context,2);
    CGRect frame = CGRectMake(2, 2, self.bounds.size.width - 3, self.bounds.size.height - 3);
    CGContextAddEllipseInRect(context,frame);
    CGContextStrokePath(context);
    
    if (_success) {
        CGContextSetRGBFillColor(context,61.0/255.f, 119.0/255.f, 238.0/255.f,0.0);
    } else {
        CGContextSetRGBFillColor(context,208/255.f, 36/255.f, 36/255.f,0.0);
    }
    
    CGContextAddEllipseInRect(context,frame);
    
    if (_selected) {
        CGContextFillPath(context);
    }
}

@end

@implementation NiceCircleView {
    CGPoint lineStartPoint;
    CGPoint lineEndPoint;
    
    NSMutableArray * touchesArray;
    NSMutableArray * touchedArray;
    BOOL success;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        touchesArray = [[NSMutableArray alloc]initWithCapacity:0];
        touchedArray = [[NSMutableArray alloc]initWithCapacity:0];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        success = 1;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [touchesArray removeAllObjects];
    [touchedArray removeAllObjects];
    success = 1;
    if (touch) {
        CGPoint touchPoint = [touch locationInView:self];
        for (int i = 0; i < _buttonArray.count; i++) {
            GesturePasswordButton * buttonTemp = ((GesturePasswordButton *)[_buttonArray objectAtIndex:i]);
            [buttonTemp setSuccess:YES];
            [buttonTemp setSelected:NO];
            if (CGRectContainsPoint(buttonTemp.frame,touchPoint)) {
                CGRect frameTemp = buttonTemp.frame;
                CGPoint point = CGPointMake(frameTemp.origin.x + frameTemp.size.width / 2,frameTemp.origin.y + frameTemp.size.height / 2);
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",point.x],@"x",[NSString stringWithFormat:@"%f",point.y],@"y", nil];
                [touchesArray addObject:dict];
                lineStartPoint = touchPoint;
            }
            [buttonTemp setNeedsDisplay];
        }
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        CGPoint touchPoint = [touch locationInView:self];
        for (int i = 0; i < _buttonArray.count; i++) {
            GesturePasswordButton * buttonTemp = ((GesturePasswordButton *)[_buttonArray objectAtIndex:i]);
            if (CGRectContainsPoint(buttonTemp.frame,touchPoint)) {
                if ([touchedArray containsObject:[NSString stringWithFormat:@"num%d",i]]) {
                    lineEndPoint = touchPoint;
                    [self setNeedsDisplay];
                    return;
                }
                [touchedArray addObject:[NSString stringWithFormat:@"num%d",i]];
                [buttonTemp setSelected:YES];
                [buttonTemp setNeedsDisplay];
                CGRect frameTemp = buttonTemp.frame;
                CGPoint point = CGPointMake(frameTemp.origin.x + frameTemp.size.width / 2,frameTemp.origin.y + frameTemp.size.height / 2);
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",point.x],@"x",[NSString stringWithFormat:@"%f",point.y],@"y",[NSString stringWithFormat:@"%d",i],@"num", nil];
                [touchesArray addObject:dict];
                break;
            }
        }
        lineEndPoint = touchPoint;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touchesArray count] == 0) {
        return;
    }
    NSMutableString * resultString = [NSMutableString string];
    for ( NSDictionary * num in touchesArray ){
        if(![num objectForKey:@"num"])break;
        [resultString appendString:[num objectForKey:@"num"]];
    }
    if(_style == 1){
        success = [_delegate verification:resultString];
    } else {
        success = [_delegate resetPassword:resultString];
    }
    
    for (int i=0; i<touchesArray.count; i++) {
        NSInteger selection = [[[touchesArray objectAtIndex:i] objectForKey:@"num"]intValue];
        GesturePasswordButton * buttonTemp = ((GesturePasswordButton *)[_buttonArray objectAtIndex:selection]);
        [buttonTemp setSuccess:success];
        [buttonTemp setNeedsDisplay];
    }
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    for (int i = 0; i<touchesArray.count; i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (![[touchesArray objectAtIndex:i] objectForKey:@"num"]) { //防止过快滑动产生垃圾数据
            [touchesArray removeObjectAtIndex:i];
            continue;
        }
        if (success) {
            CGContextSetRGBStrokeColor(context,61.0/255.f, 119.0/255.f, 238.0/255.f,1);//线条颜色
        } else {
            CGContextSetRGBStrokeColor(context, 208/255.f, 36/255.f, 36/255.f, 1);//红色
        }
        
        CGContextSetLineWidth(context, 5);
        CGContextMoveToPoint(context, [[[touchesArray objectAtIndex:i] objectForKey:@"x"] floatValue], [[[touchesArray objectAtIndex:i] objectForKey:@"y"] floatValue]);
        if (i < touchesArray.count - 1) {
            CGContextAddLineToPoint(context, [[[touchesArray objectAtIndex:i + 1] objectForKey:@"x"] floatValue],[[[touchesArray objectAtIndex:i + 1] objectForKey:@"y"] floatValue]);
        } else{
            if (success) {
                CGContextAddLineToPoint(context, lineEndPoint.x,lineEndPoint.y);
            }
        }
        CGContextStrokePath(context);
    }
}

/**
 重新绘制
 */
- (void)enterArgin {
    [touchesArray removeAllObjects];
    [touchedArray removeAllObjects];
    for (int i = 0; i < _buttonArray.count; i++) {
        GesturePasswordButton * buttonTemp = ((GesturePasswordButton *)[_buttonArray objectAtIndex:i]);
        [buttonTemp setSelected:NO];
        [buttonTemp setSuccess:YES];
        [buttonTemp setNeedsDisplay];
    }
    [self setNeedsDisplay];
}

@end


@implementation GesturePasswordView

/**
 初始化
 
 @param frame <#frame description#>
 @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        NSMutableArray *buttonArray = [[NSMutableArray alloc]initWithCapacity:0];
        NSInteger sizeWidth = 280;
        UIView *circlebgView = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width - sizeWidth) / 2, 15, sizeWidth, sizeWidth)];
        for (int i = 0; i < 9; i++) {
            NSInteger row = i / 3;
            NSInteger col = i % 3;
            NSInteger distance = sizeWidth / 3;
            NSInteger size = distance / 1.5;
            NSInteger margin = size / 4;
            GesturePasswordButton * gesturePasswordButton = [[GesturePasswordButton alloc]initWithFrame:CGRectMake(col * distance + margin, row * distance, size, size)];
            [gesturePasswordButton setTag:i + 1000];
            [circlebgView addSubview:gesturePasswordButton];
            [buttonArray addObject:gesturePasswordButton];
        }
        [self addSubview:circlebgView];
        
        _circleView = [[NiceCircleView alloc]initWithFrame:circlebgView.frame];
        [_circleView setButtonArray:buttonArray];
        [self addSubview:_circleView];
        
    }
    
    return self;
}

@end
