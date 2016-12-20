//
//  SSWaveView.m
//  SSWaveView
//
//  Created by Steven on 15/6/13.
//  Copyright (c) 2015年 Neva. All rights reserved.
//

#import "SSWaveView.h"

@interface SSWaveView()
{
    // 当前y轴震幅
    CGFloat mCurrentYAmplitude;
    
    // 当前x轴位移
    CGFloat mCurrentXOffset;
    
    // 变换系数，是否为加
    BOOL mIsPlus:YES;
    
    // 是否已经初始化
    BOOL mIsInited;
}

@property (nonatomic, strong) CAShapeLayer *circleLayer;
///当前装满程度
@property (nonatomic, assign) CGFloat currentProgress;

@property (nonatomic) int i;

@end


@implementation SSWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initWaveView];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initWaveView];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.circleLayer.frame = self.bounds;
}

- (void)initWaveView
{
    self.i = 0;
    
    self.backgroundColor = [UIColor clearColor];
    
    
    self.minAmplitude = 0.5f;
    self.maxAmplitude = 1.0f;
    self.currentProgress = 1.f;
    self.progress = 0.5f;
    
    
    self.waveSepeed = 1;
    self.controllWaveHeight = 20.f;
    self.waveWidth = 180.f;
    
    
    
    /****** 添加绘制图层 ******/
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.path          = [self pathWith:-1].CGPath;
    self.circleLayer.lineWidth     = 2.f;
    [self.layer addSublayer:self.circleLayer];
    
    // 设置默认填充颜色
    self.fillColor = [UIColor colorWithRed:86/255.0f green:202/255.0f blue:139/255.0f alpha:1];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    self.circleLayer.fillColor = fillColor.CGColor;
    self.circleLayer.strokeColor = UIColor.clearColor.CGColor;
}

- (void)startAnimate
{
    _isAnimation = YES;
    [self animateWave];
}
- (void)stopAnimate
{
    _isAnimation = NO;
}

-(void)animateWave
{
    CABasicAnimation *circleAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    circleAnim.removedOnCompletion = NO;
    circleAnim.fillMode = kCAFillModeForwards;
    circleAnim.duration = 0.5;
    circleAnim.timingFunction = [CAMediaTimingFunction functionWithName:@"linear"];
    int num = (int)(4 / self.waveSepeed);
    if (self.i % num == 0) {
        self.circleLayer.path = [self pathWith:-1].CGPath;
    }
    
    if (self.currentProgress > self.progress) {
        self.currentProgress -= self.progress / num;
    }
    if (self.currentProgress < self.progress) {
        self.currentProgress = self.progress;
    }
    circleAnim.fromValue = (__bridge id)(self.circleLayer.path);
    circleAnim.toValue   = (__bridge id)[self pathWith:self.i % num].CGPath;
    circleAnim.delegate = self;
    self.circleLayer.path = [self pathWith:self.i % num].CGPath;
    [self.circleLayer addAnimation:circleAnim forKey:[NSString stringWithFormat:@"animateCirclePath: %@", [NSDate date]]];
    
    self.i++;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && self.isAnimation) {
        [self animateWave];
    }
    else {
        _isAnimation = NO;
    }
}


- (UIBezierPath *)pathWith:(int)tag {
    CGFloat height = self.frame.size.height;
    // TODO: Find what progress mean.
    CGFloat py = 0.0;//height*self.currentProgress;
    CGFloat px = - (tag+1) * self.waveWidth * self.waveSepeed;
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(px, py)];
    BOOL isAdd = YES;
    while (px<self.frame.size.width+((4/self.waveSepeed)-tag) * self.waveWidth * self.waveSepeed) {
        px += self.waveWidth;
        [bezierPath addQuadCurveToPoint:CGPointMake(px, py) controlPoint:CGPointMake(px-self.waveWidth/2.0, py+(isAdd?self.controllWaveHeight:-self.controllWaveHeight)*(tag%1==0? self.maxAmplitude:self.minAmplitude))];
        isAdd = !isAdd;
    }
    [bezierPath addLineToPoint:CGPointMake(px, height+1)];
    [bezierPath addLineToPoint:CGPointMake(- (tag+1) * self.waveWidth, height+1)];
    [bezierPath addLineToPoint:CGPointMake(- (tag+1) * self.waveWidth, py)];
    [bezierPath closePath];
    
    return bezierPath;
}

@end
