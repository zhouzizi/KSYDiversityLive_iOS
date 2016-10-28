#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <TuSDKVideo/TuSDKVideo.h>
#import <TuSDK/TuSDK.h>

#pragma mark - KSYCameraSouceDelegate
@class KSYCameraSource;
@protocol KSYCameraSourceDelegate <NSObject>

@optional
- (void)capSource:(KSYCameraSource *)source pixelBuffer:(CVPixelBufferRef)pixelBuffer time:(CMTime)frameTime;

@end

@interface KSYCameraSource : NSObject
#pragma mark - property
@property (nonatomic, weak) id<KSYCameraSourceDelegate>delegate;
@property (nonatomic, readwrite, assign) BOOL isRunning;
@property (nonatomic, readonly)   UIView *cameraView;
@property (nonatomic, assign)     AVCaptureDevicePosition avPostion;
@property (nonatomic, copy)       NSString *sessionPreset;
@property (nonatomic, assign)     CGSize outputSize;
#pragma mark - method
- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition cameraView:(UIView *)view;
- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition cameraView:(UIView *)view videoSize:(CGSize)outputSize;
- (void)toggleCamera;
- (void)destory;
- (void)switchFilterCode:(NSString *)code;
- (void)startRunning;
- (void)stopRunning;
- (void)setFramerate:(NSUInteger)fps;
- (AVCaptureFlashMode)getFlashMode;
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;

@end
