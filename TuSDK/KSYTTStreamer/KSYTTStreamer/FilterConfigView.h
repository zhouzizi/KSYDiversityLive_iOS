//
//  FilterConfigView.h
//  TuSDKVideoDemo
//
//  Created by Yanlin on 4/22/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TuSDK/TuSDK.h>
#import <TuSDKVideo/TuSDKVideo.h>

#pragma mark - FilterSeekbar
@class FilterSeekbar;
/**
 *  滤镜配置拖动栏委托
 */
@protocol FilterSeekbarDelegate <NSObject>
/**
 *  配置数据改变
 *
 *  @param seekbar 滤镜配置拖动栏
 *  @param arg     滤镜参数
 */
- (void)onSeekbar:(FilterSeekbar *)seekbar changedFilterArg:(TuSDKFilterArg *)arg;
@end

/**
 *  滤镜配置拖动栏
 */
@interface FilterSeekbar : UIView<TuSDKICSeekBarDelegate>
/**
 *  滤镜配置拖动栏委托
 */
@property (nonatomic, assign) id<FilterSeekbarDelegate> delegate;

/**
 *  百分比控制条
 */
@property (nonatomic, readonly) TuSDKICSeekBar *seekBar;

/**
 *  标题视图
 */
@property (nonatomic, readonly) UILabel *titleView;

/**
 *  计数视图
 */
@property (nonatomic, readonly) UILabel *numberView;

/**
 *  滤镜配置参数
 */
@property (nonatomic, retain) TuSDKFilterArg *filterArg;

/**
 *  重置参数
 */
- (void)reset;
@end

#pragma mark - FilterConfigView
@class FilterConfigView;

/**
 *  滤镜配置视图委托
 */
@protocol FilterConfigViewDelegate <NSObject>
/**
 *  通知重新绘制
 *
 *  @param filterConfigView 滤镜配置视图
 */
- (void)onRequestRenderWithFilterConfigView:(FilterConfigView *)filterConfigView;
@end

/**
 *  滤镜配置视图
 */
@interface FilterConfigView : TuSDKFilterConfigViewBase<FilterSeekbarDelegate>
{
    //
    TuSDKFilterWrap *_filterWrap;
}

/**
 *  滤镜配置视图委托
 */
@property (nonatomic, assign) id<FilterConfigViewDelegate> delegate;

/**
 *  重置按钮
 */
@property (nonatomic, readonly) UIButton *resetButton;

/**
 *  显示状态按钮
 */
@property (nonatomic, readonly) UIButton *stateButton;

/**
 *  状态背景
 */
@property (nonatomic, readonly) UIView *stateBg;

/**
 *  配置包装
 */
@property (nonatomic, readonly) UIView *configWrap;

/**
 *  设置隐藏为默认状态
 */
- (void)hiddenDefault;

/**
 *  创建滤镜配置拖动栏
 *
 *  @param top 顶部距离
 *
 *  @return 滤镜配置拖动栏
 */
- (FilterSeekbar *)buildSeekbarWithTop:(CGFloat)top;
@end
