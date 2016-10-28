//
//  TuSDKLiveVideoCamera.h
//  TuSDKVideo
//
//  Created by Yanlin on 3/9/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import "TuSDKVideoCameraBase.h"

#pragma mark - TuSDKLiveVideoCameraDelegate

@class TuSDKLiveVideoCamera;
/**
 *  相机事件委托
 */
@protocol TuSDKLiveVideoCameraDelegate <TuSDKVideoCameraDelegate>

/**
 *  获取滤镜处理后的帧数据, pixelFormatType 为 lsqFormatTypeBGRA 或 lsqFormatTypeYUV420F 时调用
 *
 *  @param camera      相机
 *  @param pixelBuffer 帧数据, CVPixelBufferRef 类型, 默认为 kCVPixelFormatType_32BGRA 格式
 *  @param frameTime   帧时间戳
 */
- (void)onVideoCamera:(TuSDKLiveVideoCamera *)camera bufferData:(CVPixelBufferRef)pixelBuffer time:(CMTime)frameTime;

@optional
/**
 *  获取滤镜处理后的帧原始数据, pixelFormatType 为 lsqFormatTypeRawData 时调用
 *
 *  @param camera      相机
 *  @param bytes       帧数据
 *  @param bytesPerRow bytesPerRow
 *  @param imageSize   尺寸
 *  @param frameTime   帧时间戳
 */
- (void)onVideoCamera:(TuSDKLiveVideoCamera *)camera rawData:(unsigned char *)bytes bytesPerRow:(NSUInteger)bytesPerRow imageSize:(CGSize)imageSize time:(CMTime)frameTime;

@end

#pragma mark - TuSDKLiveVideoCamera

@protocol TuSDKLiveVideoCameraDelegate;

/**
 *  视频直播相机 (采集 + 处理 + 输出)
 *
 *  用于和其他平台进行对接
 */
@interface TuSDKLiveVideoCamera : TuSDKVideoCameraBase

/**
 *  初始化相机
 *
 *  @param sessionPreset  相机分辨率类型
 *  @param cameraPosition 相机设备标识 （前置或后置）
 *  @param cameraView     相机显示容器视图
 *
 *  @return 相机对象
 */
+ (instancetype)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition cameraView:(UIView *)view;

/**
 *  相机事件委托
 */
@property (nonatomic, assign) id<TuSDKLiveVideoCameraDelegate> videoDelegate;

/**
 *  输出 PixelBuffer 格式，可选: lsqFormatTypeBGRA | lsqFormatTypeYUV420F | lsqFormatTypeRawData
 *  默认:lsqFormatTypeBGRA
 */
@property (nonatomic) lsqFrameFormatType pixelFormatType;

/**
 *  开始视频录制
 */
- (void)startRecording;

/**
 *  终止录制
 */
- (void)cancelRecording;

@end
