//
//  TuSDKVideoProcessorBase.h
//  TuSDKVide
//
//  Created by Yanlin on 3/22/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "TuSDKVideoImport.h"

/**
 A GPU Output that provides frames from external source
 */
@interface TuSDKVideoProcessorBase : GPUImageOutput
{
    NSUInteger numberOfFramesCaptured;
    CGFloat totalFrameTimeDuringCapture;
    
    GPUImageRotationMode outputRotation, internalRotation;
    
    BOOL captureAsYUV;
    GLuint luminanceTexture, chrominanceTexture;
}


/// This sets the frame rate of the camera (iOS 5 and above only)
/**
 Setting this to 0 or below will set the frame rate back to the default setting for a particular preset.
 */
@property (readwrite) int32_t frameRate;

/// This enables the benchmarking mode, which logs out instantaneous and average frame times to the console
@property(readwrite, nonatomic) BOOL runBenchmark;

/// This determines the rotation applied to the output image, based on the source material
@property(readwrite, nonatomic) UIInterfaceOrientation outputImageOrientation;

@property(nonatomic, assign) AVCaptureDevicePosition cameraPosition;

/// These properties determine whether or not the two camera orientations should be mirrored. By default, both are NO.
@property(readwrite, nonatomic) BOOL horizontallyMirrorFrontFacingCamera, horizontallyMirrorRearFacingCamera;

/**
 *  是否为前置摄像头
 */
@property (readonly, getter = isFrontFacingCameraPresent) BOOL frontFacingCameraPresent;

/**
 *  是否为后置摄像头
 */
@property (readonly, getter = isBackFacingCameraPresent) BOOL backFacingCameraPresent;

/**
 *  初始化
 *
 *  支持： kCVPixelFormatType_420YpCbCr8BiPlanarFullRange | kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange kCVPixelFormatType_32BGRA
 *
 *  @param pixelFormatType          原始采样的pixelFormat Type
 *  @param adjustByVideoOrientation 原始采样已做过朝向处理
 *
 *  @return
 */
- (id)initWithFormatType:(OSType)pixelFormatType adjustByVideoOrientation:(BOOL)adjustByVideoOrientation;

/**
 *  初始化
 *
 *  @param videoOutput 视频源
 *
 *  @return 
 */
- (id)initWithVideoDataOutput:(AVCaptureVideoDataOutput *)videoOutput;

/**
 *  Process a video sample
 *
 *  @param sampleBuffer sampleBuffer Buffer to process
 */
- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 *  Process a pixelBuffer
 *
 *  @param pixelBuffer pixelBuffer to process
 */
- (void)processPixelBuffer:(CVPixelBufferRef)cameraFrame frameTime:(CMTime)currentTime;

/// @name Benchmarking

/** When benchmarking is enabled, this will keep a running average of the time from uploading, processing, and final recording or display
 */
- (CGFloat)averageFrameDurationDuringCapture;

- (void)resetBenchmarkAverage;

@end
