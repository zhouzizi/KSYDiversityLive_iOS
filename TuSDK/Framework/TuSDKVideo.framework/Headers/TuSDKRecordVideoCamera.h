//
//  TuSDKRecordVideoCamera.h
//  TuSDKVideo
//
//  Created by Yanlin on 3/9/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import "TuSDKVideoCameraBase.h"

#pragma mark - TuSDKRecordVideoCameraDelegate
@class TuSDKRecordVideoCamera;
/**
 *  相机事件委托
 */
@protocol TuSDKRecordVideoCameraDelegate <TuSDKVideoCameraDelegate>
/**
 *  视频录制完成
 *
 *  @param camerea    相机
 *  @param duration   录制时长
 *  @param videoAsset Asset对象
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea movieRecordCompleted:(CMTime)duration asset:(id<TuSDKTSAssetInterface>)videoAsset;

/**
 *  视频录制出错
 *
 *  @param camerea 相机
 *  @param error   错误对象
 */
- (void)onVideoCamera:(TuSDKRecordVideoCamera *)camerea failedWithError:(NSError*)error;

@end

#pragma mark - TuSDKRecordVideoCamera
/**
 *  视频录制相机 (采集 + 处理 + 录制)
 */
@interface TuSDKRecordVideoCamera : TuSDKVideoCameraBase

/**
 *  初始化相机
 *
 *  @param sessionPreset  相机分辨率
 *  @param cameraPosition 相机设备标识 （前置或后置）
 *  @param view           相机显示容器视图
 *
 *  @return 相机对象
 */
+ (instancetype)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition cameraView:(UIView *)view;

/**
 *  相机事件委托
 */
@property (nonatomic, assign) id<TuSDKRecordVideoCameraDelegate> videoDelegate;

/**
 *  录制视频的总时长. 达到指定时长后，自动停止录制 (默认: 10s)
 */
@property (nonatomic, assign) NSUInteger limitDuration;

/**
 *  保存到系统相册的相册名称
 */
@property (nonatomic, copy) NSString *saveToAlbumName;

/**
 *  开始视频录制
 */
- (void)startRecording;

/**
 *  完成视频录制
 */
- (void)finishRecording;

/**
 *  终止录制
 */
- (void)cancelRecording;

/**
 *  是否正在录制
 *
 *  @return 
 */
- (BOOL)isRecording;

@end
