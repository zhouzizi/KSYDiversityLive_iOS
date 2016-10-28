#import "KSYTTDemoVC.h"
#import "FilterConfigView.h"


@interface KSYTTDemoVC ()<UIGestureRecognizerDelegate,KSYCameraSourceDelegate>
{
    UIView              *_preview;
    NSURL               *_hostURL;
}

@end

@implementation KSYTTDemoVC

- (BOOL)prefersStatusBarhidden{
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}
- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
- (void)loadView{
    [super loadView];
    _videoFilters = @[@"Glare",@"VideoFair",@""];
    _videoFilterIndex = 1;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopRunning];
}
- (void)lsqInitView{
    [super lsqInitView];
    [self initSettingsAndStartPreview];
}
- (void)initSettingsAndStartPreview
{
    CGSize videoSize = CGSizeMake(320, 480);
    self.flashModeIndex = 2;
    [self updateFlashModeStatus];
    AVCaptureDevicePosition pos = [AVCaptureDevice lsqFirstFrontCameraPosition];
    if (!pos)
    {
        pos = [AVCaptureDevice lsqFirstBackCameraPosition];
    }
    _preview = [[UIView alloc]initWithFrame:self.view.frame];
    [self.view insertSubview:_preview atIndex:0];
    _cameraSource = [[KSYCameraSource alloc] initWithCameraPosition:pos cameraView:_preview videoSize:videoSize];
    _cameraSource.delegate = self;
    [_cameraSource startRunning];
    
    
    //set streameBase
    _streamerBase = [[KSYStreamerBase alloc]initWithDefaultCfg];
    [self defaultStramCfg];

    
    //set audio path
    _aMixer = [[KSYAudioMixer alloc]init];
    _audioCapDev = [[KSYAUAudioCapture alloc]init];
    [self setupAudioPath];
    
}
- (void) defaultStramCfg{
    // stream default settings
    _streamerBase.videoCodec = KSYVideoCodec_X264;
    _streamerBase.videoInitBitrate =  600;
    _streamerBase.videoMaxBitrate  = 1000;
    _streamerBase.videoMinBitrate  =    0;
    _streamerBase.audiokBPS        =   48;
    _streamerBase.enAutoApplyEstimateBW     = YES;
    _streamerBase.shouldEnableKSYStatModule = YES;
    _streamerBase.videoFPS = 15;
    _streamerBase.logBlock = ^(NSString* str){
        NSLog(@"%@", str);
    };
    _hostURL = [NSURL URLWithString:@"rtmp://test.uplive.ksyun.com/live/kingsoft"];
}

- (void) setupAudioPath {
    __weak typeof(self) weakSelf = self;
    _micTrack = 0;
    _audioCapDev.audioProcessingCallback = ^(CMSampleBufferRef buf){
        if (![weakSelf.streamerBase isStreaming]){
            return;
        }
        [weakSelf.aMixer processAudioSampleBuffer:buf of:weakSelf.micTrack];
    };
    
    // mixer 的主通道为麦克风,时间戳以住通道为准
    _aMixer.mainTrack = _micTrack;
    [_aMixer setTrack:_micTrack enable:YES];

    _aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf){
        [weakSelf.streamerBase processAudioSampleBuffer:buf];
    };
    // default volume
    [_aMixer setMixVolume:1.0 of:_micTrack];
}

- (void)switchFilter:(NSString *)code
{
    dispatch_async(self.sessionQueue, ^{
        [_cameraSource switchFilterCode:code];
    });
}
- (void)dealloc {
    self.sessionQueue = nil;
    [_cameraSource destory];
}
- (void)stopRunning {
    dispatch_async(self.sessionQueue, ^{
        [_cameraSource stopRunning];
        [_audioCapDev stopCapture];
    });
}
- (void)startRunning {
    self.mActionButton.enabled = NO;
    dispatch_async(self.sessionQueue, ^{
        [_audioCapDev startCapture];
    });
}

- (void)onConfigButtonClicked:(id)sender
{
    if (sender == self.mCloseButton)
    {
        [self dismissModalViewControllerAnimated];
    }
    else if (sender == self.mFilterButton)
    {
        _beautyEnabled = !_beautyEnabled;
        
        NSString *code = _beautyEnabled ? [_videoFilters objectAtIndex:_videoFilterIndex] : @"";
        
        [self switchFilter:code];
        
        [self updateBeautyStatus:_beautyEnabled];
    }
    else if (sender == self.mSettingButton)
    {
        
    }
    else if (sender == self.mToggleCameraButton)
    {
        [_cameraSource toggleCamera];
        
        [self.mFlashButton setEnabled:_cameraSource.avPostion == AVCaptureDevicePositionBack];
    }
    else if (sender == self.mFlashButton)
    {
        self.flashModeIndex++;
        
        if (self.flashModeIndex >=3)
        {
            self.flashModeIndex = 0;
        }
        
        [self updateFlashModeStatus];
        
        dispatch_async(self.sessionQueue, ^{
            [_cameraSource setFlashMode:[self getFlashModeByValue:self.flashModeIndex]];
        });
    }
}
- (void)startStream:(UIButton *)btn{
    [super startStream:btn];
    if (btn.isSelected) {
        [self startRunning];
        if (_streamerBase.streamState == KSYStreamStateIdle ||
            _streamerBase.streamState == KSYStreamStateError) {
            [_streamerBase startStream:_hostURL];
        }
        else{
            [_streamerBase stopStream];
        }
    }
    else{
        [_streamerBase stopStream];
    }
}
- (void)updateFlashModeStatus
{
    [super updateFlashModeStatus];
    [self.mFlashButton setEnabled:_cameraSource.avPostion == AVCaptureDevicePositionBack];
}

- (AVCaptureFlashMode)getFlashModeByValue:(NSInteger)value
{
    if (value == 2)
    {
        return AVCaptureFlashModeAuto;
    }
    else if(value == 1)
    {
        return AVCaptureFlashModeOn;
    }
    
    return AVCaptureFlashModeOff;
}

- (void)onActionHandle:(id)sender
{

}

#pragma mark - KSYCameraSourceDelegate

- (void)capSource:(KSYCameraSource *)source pixelBuffer:(CVPixelBufferRef)pixelBuffer time:(CMTime)frameTime{
    [_streamerBase processVideoPixelBuffer:pixelBuffer timeInfo:frameTime];
}

@end
