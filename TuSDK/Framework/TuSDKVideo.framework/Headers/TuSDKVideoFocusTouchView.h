//
//  TuSDKVideoFocusTouchView.h
//  TuSDKVideo
//
//  Created by Yanlin on 4/18/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuSDKVideoImport.h"
#import "TuSDKFilterConfigProtocol.h"
#import "TuSDKVideoSourceProtocol.h"


#pragma mark  - TuSDKVideoFocusTouchView
/**
 *  相机聚焦触摸视图
 */
@interface TuSDKVideoFocusTouchView : TuSDKCPFocusTouchViewBase <TuSDKVideoCameraExtendViewInterface>
{
    @protected
    // 聚焦视图 (如果不设定，将使用 TuSDKICFocusRangeView)
    UIView<TuSDKICFocusRangeViewProtocol> *_rangeView;
}

/**
 *  聚焦视图 (如果不设定，将使用 TuSDKICFocusRangeView)
 */
@property (nonatomic, readonly) UIView<TuSDKICFocusRangeViewProtocol> *rangeView;

/**
 *  顶部边距
 */
@property (nonatomic) NSInteger topSpace;

/**
 *  是否显示辅助线
 */
@property (nonatomic) BOOL displayGuideLine;

/**
 *  是否禁止触摸聚焦 (默认: YES)
 */
@property (nonatomic) BOOL disableTapFocus;

/**
 *  是否开启脸部特征检测 (智能美颜 | 动态贴纸 都需要开启该选项)
 */
@property (nonatomic) BOOL enableFaceFeatureDetection;

/**
 *  通知选取范围视图
 *
 *  @param point 聚焦点
 */
- (void)notifyRangeViewWithPoint:(CGPoint)point;

@end

