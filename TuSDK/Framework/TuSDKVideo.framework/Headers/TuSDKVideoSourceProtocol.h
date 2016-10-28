//
//  TuSDKVideoSourceProtocol.h
//  TuSDKVideo
//
//  Created by Yanlin on 4/20/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

/**
 *  视频输出协议
 */
@protocol TuSDKVideoSourceProtocol <NSObject>

/**
 *  系统相机对象
 */
@property (readonly) AVCaptureDevice *inputCamera;

/**
 *  摄像头位置
 */
- (AVCaptureDevicePosition)cameraPosition;

/**
 *  旋转模式
 *
 *  @return
 */
- (GPUImageRotationMode)getInternalRotation;

/**
 *  设备当前朝向
 *
 *  @return
 */
- (UIDeviceOrientation)getDeviceOrientation;

/**
 *  获取聚焦视图
 *
 *  @return
 */
- (UIView<TuSDKVideoCameraExtendViewInterface> *)getFocusTouchView;

/**
 *  更新脸部信息
 *
 *  @param points
 */
- (void)updateFaceFeatures:(NSArray<NSValue *> *)points;

@end
