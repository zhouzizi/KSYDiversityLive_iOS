//
//  FilterConfigView.m
//  TuSDKVideoDemo
//
//  Created by Yanlin on 4/22/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import "FilterConfigView.h"

#pragma mark - FilterSeekbar
/**
 *  滤镜配置拖动栏
 */
@implementation FilterSeekbar
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

-(void)lsqInitView;
{
    // 标题视图
    _titleView = [UILabel initWithFrame:CGRectMake(self.getSizeWidth - 40, [self getCenterY:40], 40, 16)
                               fontSize:12
                                  color:lsqRGB(255, 255, 255)
                               aligment:NSTextAlignmentCenter];
    [self addSubview:_titleView];
    
    // 计数视图
    _numberView = [UILabel initWithFrame:CGRectMake(self.getSizeWidth - 40, _titleView.getBottomY, 40, 24)
                                fontSize:18
                                   color:lsqRGB(255, 255, 255)
                                aligment:NSTextAlignmentCenter];
    [self addSubview:_numberView];
    
    // 百分比控制条
    _seekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(0, 10, _titleView.getOriginX - 20, self.getSizeHeight - 20)];
    _seekBar.delegate = self;
    [self addSubview:_seekBar];
}

// 滤镜配置参数
- (void)setFilterArg:(TuSDKFilterArg *)filterArg;
{
    _filterArg = filterArg;
    if (!_filterArg) return;
    _seekBar.progress = _filterArg.precent;
    NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", _filterArg.key];
    _titleView.text = NSLocalizedString(title, @"");
    
    [self setProgress: _seekBar.progress];
}

// 设置百分比
- (void)setProgress:(CGFloat)progress;
{
    if (_filterArg) {
        _filterArg.precent = progress;
    }
    
    _numberView.text = [NSString stringWithFormat:@"%02ld", (long)(progress * 100)];
}

/**
 *  重置参数
 */
- (void)reset;
{
    if (!_filterArg) return;
    [_filterArg reset];
    [self setFilterArg:_filterArg];
}

#pragma mark - TuSDKICSeekBarDelegate
/**
 *  进度改变
 *
 *  @param seekbar  百分比控制条
 *  @param progress 进度百分比
 */
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress;
{
    [self setProgress:progress];
    if (self.delegate) {
        [self.delegate onSeekbar:self changedFilterArg:self.filterArg];
    }
}
@end

#pragma mark - FilterConfigView
/**
 *  滤镜配置视图
 */
@interface FilterConfigView(){
    // 是否正在进行动画
    BOOL _isAniming;
    // 滤镜配置拖动栏列表
    NSMutableArray *_seekBars;
}
@end

@implementation FilterConfigView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}

-(void)lsqInitView;
{
    
    // 重置按钮
    _resetButton = [UIButton buttonWithFrame:CGRectMake(10, 10, 55, 30)
                                       title:NSLocalizedString(@"lsq_reset", @"重置")
                                        font:lsqFontSize(16)
                                       color:[UIColor whiteColor]];
    [_resetButton setCornerRadius:_resetButton.getSizeHeight * 0.5];
    _resetButton.backgroundColor = lsqRGB(255, 102, 51);
    [_resetButton addTouchUpInsideTarget:self action:@selector(handleResetAction)];
    [self addSubview:_resetButton];
    
    // 状态背景
    _stateBg = [UIView initWithFrame:CGRectMake(self.getSizeWidth - 50, 5, 44, 44)];
    _stateBg.backgroundColor = lsqRGBA(0, 0, 0, 0.7);
    [_stateBg setCornerRadius:_stateBg.getSizeWidth * 0.5];
    [self addSubview:_stateBg];
    
    // 显示状态按钮
    _stateButton = [[UIButton alloc] initWithFrame:_stateBg.frame];
    [_stateButton setImage:[UIImage imageNamed:@"icon_filter_config"] forState:UIControlStateNormal];
    [_stateButton addTouchUpInsideTarget:self action:@selector(handleShowStateAction)];
    [_stateButton setCornerRadius:_stateButton.getSizeHeight * 0.5];
    _stateButton.layer.borderWidth = 2;
    _stateButton.layer.borderColor = lsqRGBA(0, 0, 0, 0).CGColor;
    _stateButton.backgroundColor = lsqRGB(255, 102, 51);
    
    [self addSubview:_stateButton];
    // 配置包装
    _configWrap = [UIView initWithFrame:CGRectMake(10, _stateButton.getBottomY + 10, self.getSizeWidth - 20, 100)];
    [self addSubview:_configWrap];
    
    [self hiddenDefault];
}

/**
 *  设置隐藏为默认状态
 */
- (void)hiddenDefault;
{
    self.hidden = YES;
    _resetButton.hidden = YES;
    _configWrap.hidden = YES;
    [_configWrap setAlpha:0];
    [_stateButton setAlpha:0.7];
    [_stateBg setAlpha:0];
    [_stateBg setSizeHeight:_stateButton.getSizeHeight];
}

// 滤镜包装对象
- (void)setFilterWrap:(TuSDKFilterWrap *)filterWrap;
{
    _filterWrap = filterWrap;
    [self clean];
    
    if (!_filterWrap || !_filterWrap.filterParameter || !_filterWrap.filterParameter.args) {
        [self hiddenDefault];
        return;
    }
    
    self.hidden = NO;
    [self resetConfigView];
}

// 清理选项
- (void)clean;
{
    [_configWrap removeAllSubviews];
    _seekBars = nil;
}

/**
 *  重置滤镜配置选项
 */
- (void)handleResetAction;
{
    if (!_seekBars) return;
    
    for (FilterSeekbar *seekbar in _seekBars)
    {
        [seekbar reset];
    }
    
    [self requestRender];
    [UIView animateWithDuration:0.26 animations:^{
        [_stateBg setSizeHeight:_configWrap.getBottomY];
    }];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
{
    if (self.hidden) return nil;
    
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self){
        return nil;
    }
    return hitView;
}

/**
 *  设置滤镜配置选线显示状态
 */
- (void)handleShowStateAction;
{
    if (_isAniming) return;
    _isAniming = YES;
    
    BOOL isShow = !_configWrap.hidden;
    _resetButton.hidden = isShow;
    _configWrap.hidden = NO;
    
    [UIView animateWithDuration:0.26 animations:^{
        if (isShow) {
            [_stateBg setSizeHeight:_stateButton.getSizeHeight];
            [_stateBg setAlpha:0];
            [_stateButton rotationWithDegrees:0];
            [_stateButton setAlpha:0.7f];
            [_configWrap setAlpha:0];
        }
        else{
            [_stateBg setSizeHeight:_configWrap.getBottomY];
            [_stateBg setAlpha:1.f];
            [_stateButton rotationWithDegrees:90];
            [_stateButton setAlpha:1.f];
            [_configWrap setAlpha:1.f];
        }
    } completion:^(BOOL finished) {
        if (finished && isShow) {
            _configWrap.hidden = YES;
        }
        _isAniming = NO;
    }];
}

/**
 *  重置配置视图
 */
- (void)resetConfigView;
{
    NSArray * args = _filterWrap.filterParameter.args;
    
    _seekBars = [NSMutableArray arrayWithCapacity:args.count];
    CGFloat top = 0;
    for (TuSDKFilterArg *arg in args) {
        FilterSeekbar * seekbar = [self buildSeekbarWithTop:top];
        if (seekbar) {
            seekbar.filterArg = arg;
            seekbar.delegate = self;
            [_seekBars addObject:seekbar];
            [_configWrap addSubview:seekbar];
            top = seekbar.getBottomY;
        }
    }
    [_configWrap setSizeHeight:top];
    
    [UIView animateWithDuration:0.26 animations:^{
        [_stateBg setSizeHeight:_configWrap.getBottomY];
    }];
}

/**
 *  创建滤镜配置拖动栏
 *
 *  @param top 顶部距离
 *
 *  @return 滤镜配置拖动栏
 */
- (FilterSeekbar *)buildSeekbarWithTop:(CGFloat)top;
{
    FilterSeekbar *seekbar = [FilterSeekbar initWithFrame:CGRectMake(20, top, self.getSizeWidth - 40, 50)];
    return seekbar;
}

// 请求渲染
- (void)requestRender;
{
    if (self.delegate) {
        [self.delegate onRequestRenderWithFilterConfigView:self];
    }
    else if (_filterWrap)
    {
        [_filterWrap submitParameter];
    }
}
#pragma mark - FilterSeekbarDelegate
/**
 *  配置数据改变
 *
 *  @param seekbar 滤镜配置拖动栏
 *  @param arg     滤镜参数
 */
- (void)onSeekbar:(FilterSeekbar *)seekbar changedFilterArg:(TuSDKFilterArg *)arg;
{
    [self requestRender];
}
@end

