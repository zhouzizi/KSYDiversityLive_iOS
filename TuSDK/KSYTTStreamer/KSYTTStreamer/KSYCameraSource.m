#import "KSYCameraSource.h"
#import <TuSDK/TuSDK.h>
#import <TuSDKVideo/TuSDKVideo.h>
#import "FilterConfigView.h"
@interface KSYCameraSource ()<TuSDKLiveVideoCameraDelegate>
{
    TuSDKLiveVideoCamera *_camera;
    lsqRatioType _currentRatioType;
    lsqRatioType _screenRatioType;
    AVCaptureFlashMode _flashMode;
    FilterConfigView *_filterConfigView;
}

@end

@implementation KSYCameraSource
- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition cameraView:(UIView *)view{
    return [self initWithCameraPosition:cameraPosition cameraView:view videoSize:CGSizeZero];
}
- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition cameraView:(UIView *)view videoSize:(CGSize)outputSize{
    self = [super init];
    if (self) {
        _avPostion = cameraPosition;
        _cameraView = view;
        _outputSize = outputSize;
        _flashMode = AVCaptureFlashModeAuto;
    }
    return self;
}
- (NSString *)sessionPreset{
    if (!_sessionPreset) {
        _sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _sessionPreset;
}
- (void)startCamera{
    [self destoryCamera];
    _camera = [TuSDKLiveVideoCamera initWithSessionPreset:self.sessionPreset cameraPosition:self.avPostion cameraView:self.cameraView];
    _camera.videoDelegate = self;
    _camera.outputSize = _outputSize;
    _camera.disableTapFocus = YES;
    _camera.disableContinueFoucs = NO;
    _camera.cameraViewRatio = 0;
    _camera.regionViewColor = [UIColor blackColor];
    _camera.disableMirrorFrontFacing = NO;
    _camera.frameRate = 15;
    [_camera flashWithMode:_flashMode];
    [_camera switchFilterWithCode:nil];
    [_camera tryStartCameraCapture];
    CGRect rect = self.cameraView.frame;
    _filterConfigView = [[FilterConfigView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + 80, rect.size.width, rect.size.height - 80)];
    [self.cameraView.superview addSubview:_filterConfigView];
}
- (void)destoryCamera{
    if (_camera) {
        [_camera destory];
        _camera = nil;
    }
}
- (void)toggleCamera{
    [_camera rotateCamera];
    self.avPostion = _camera.cameraPosition;
}
- (void)switchFilterCode:(NSString *)code{
    [_camera switchFilterWithCode:code];
}
- (void)startRunning{
    [self startCamera];
    [_camera startRecording];
}
- (void)stopRunning{
    if (!_camera) {
        return;
    }
    [self destoryCamera];
    [_camera cancelRecording];
}
- (void)setFramerate:(NSUInteger)fps{
    if (_camera) {
        [_camera setFrameRate:(int32_t)fps];
    }
}
- (AVCaptureFlashMode)getFlashMode{
    return _flashMode;
}
- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    _flashMode = flashMode;
    if (_camera) {
        [_camera flashWithMode:flashMode];
    }
}
- (void)destory{
    [self destoryCamera];
}
#pragma mark - TuSDKVideoCameraDelegate
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera stateChanged:(lsqCameraState)state{
    
}
- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera filterChanged:(TuSDKFilterWrap *)newFilter{
    if (_filterConfigView)
    {
        _filterConfigView.filterWrap = newFilter;
    }
}
- (void)onVideoCamera:(TuSDKLiveVideoCamera *)camera bufferData:(CVPixelBufferRef)pixelBuffer time:(CMTime)frameTime{
    if (self.delegate && [self.delegate respondsToSelector:@selector(capSource:pixelBuffer:time:)]) {
        [self.delegate capSource:self pixelBuffer:pixelBuffer time:frameTime];
    }
}
- (void)onVideoCamera:(TuSDKLiveVideoCamera *)camera rawData:(unsigned char *)bytes bytesPerRow:(NSUInteger)bytesPerRow imageSize:(CGSize)imageSize time:(CMTime)frameTime{
    
}
@end
