#import "KSYTTBaseVC.h"
#import <TuSDK/TuSDK.h>
#import <TuSDKVideo/TuSDKVideo.h>
#import "UIView+YYAdd.h"

@interface KSYTTBaseVC ()<UIGestureRecognizerDelegate>
{
    UISwipeGestureRecognizer *_leftSwipeGestureHandler;
    UISwipeGestureRecognizer *_rightSwipeGestureHandler;
    BOOL uiInited;
}
@end

@implementation KSYTTBaseVC
- (BOOL)prefersStatusBarHidden;
{
    return YES;
}
- (void)loadView;
{
    [super loadView];
    self.view.backgroundColor = lsqRGB(255, 255, 255);
    self.wantsFullScreenLayout = YES;
    [self setNavigationBarHidden:YES];
    [self setStatusBarHidden:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _muteButtonEnabled = NO;
    self.view.backgroundColor = lsqRGB(255, 255, 255);
    _sessionQueue = dispatch_queue_create("com.ksy.queue", DISPATCH_QUEUE_SERIAL);
    _leftSwipeGestureHandler = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
    _rightSwipeGestureHandler = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
    _leftSwipeGestureHandler.direction = UISwipeGestureRecognizerDirectionLeft;
    _rightSwipeGestureHandler.direction = UISwipeGestureRecognizerDirectionRight;
    _leftSwipeGestureHandler.delegate = self;
    _rightSwipeGestureHandler.delegate = self;
    if (_videoFilters.count > 1)
    {
        [self.view addGestureRecognizer:_leftSwipeGestureHandler];
        [self.view addGestureRecognizer:_rightSwipeGestureHandler];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!uiInited)
    {
        [self lsqInitView];
        [self updateBeautyStatus:_beautyEnabled];
        uiInited = YES;
    }
}
- (void)lsqInitView
{
    CGRect rect = self.view.frame;
    CGFloat buttonWidth = 44;
    CGFloat margin = 16;
    NSUInteger buttonNum = _muteButtonEnabled? 6 : 5;
    CGFloat padding = (rect.size.width - margin * 2 - buttonWidth * buttonNum)/(buttonNum-1);
    _mCloseButton = [self buildConfigButton:@"icon_closed" frame:CGRectMake(margin, 0, buttonWidth, buttonWidth)];
    _mFilterButton = [self buildConfigButton:@"icon_beauty_off" frame:CGRectMake(margin + (buttonWidth + padding)*1, 0, buttonWidth, buttonWidth)];
    _mSettingButton = [self buildConfigButton:@"icon_setting" frame:CGRectMake(margin + (buttonWidth + padding)*2, 0, buttonWidth, buttonWidth)];
    _mFlashButton = [self buildConfigButton:@"icon_flash_off" frame:CGRectMake(margin + (buttonWidth + padding)*3, 0, buttonWidth, buttonWidth)];
    if (_muteButtonEnabled)
    {
        _mMuteButton = [self buildConfigButton:@"icon_volume_on" frame:CGRectMake(margin + (buttonWidth + padding)*4, 0, buttonWidth, buttonWidth)];
        _mToggleCameraButton = [self buildConfigButton:@"icon_camera_flip" frame:CGRectMake(margin + (buttonWidth + padding)*5, 0, buttonWidth, buttonWidth)];
    }
    else
    {
        _mToggleCameraButton = [self buildConfigButton:@"icon_camera_flip" frame:CGRectMake(margin + (buttonWidth + padding)*4, 0, buttonWidth, buttonWidth)];
    }
    buttonWidth = 64;
    _mActionButton = [[UIButton alloc] initWithFrame:CGRectMake((rect.size.width - buttonWidth)/2, rect.size.height - buttonWidth - 16, buttonWidth, buttonWidth)];
    
    UIImage *image = [UIImage imageNamed:@"icon_play"];
    [_mActionButton setImage:image forState:UIControlStateNormal];
    [_mActionButton setAdjustsImageWhenHighlighted:NO];
    [_mActionButton setBackgroundColor:lsqRGB(0xff, 0x55, 0x34)];
    _mActionButton.layer.cornerRadius = buttonWidth/2;
    [_mActionButton addTouchUpInsideTarget:self action:@selector(onActionHandle:)];
    _mActionButton.hidden = YES;
    [self.view addSubview:_mActionButton];
    [self.view addSubview:self.startLiveButton];
}
@synthesize  startLiveButton = _startLiveButton;
- (UIButton *)startLiveButton {
    if (!_startLiveButton) {
        _startLiveButton = [UIButton new];
        _startLiveButton.size = CGSizeMake(self.view.width - 60, 44);
        _startLiveButton.left = 30;
        _startLiveButton.bottom = self.view.height - 50;
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startLiveButton.exclusiveTouch = YES;
        [_startLiveButton addTarget:self action:@selector(startStream:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startLiveButton;
}
- (void)startStream:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.isSelected) {
        [btn setTitle:@"结束直播" forState:UIControlStateNormal];
    }
    else{
        [btn setTitle:@"开始直播" forState:UIControlStateNormal];
    }
}
- (UIButton *)buildConfigButton:(NSString *)iconName frame:(CGRect)frame
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    
    UIImage *image = [UIImage imageNamed:iconName];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onConfigButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    return btn;
}
- (void)onConfigButtonClicked:(id)sender
{
}
- (void)onActionHandle:(id)sender
{
}
- (void)switchFilter:(NSString *)code
{
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self.view) {
        return NO;
    }
    return YES;
}
- (void)onSwipeGesture:(UISwipeGestureRecognizer *)sender;
{
    if (!_beautyEnabled) return;
    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        _videoFilterIndex--;
        if (_videoFilterIndex < 0)
        {
            _videoFilterIndex = _videoFilters.count - 1;
        }
    }
    else
    {
        _videoFilterIndex++;
        if (_videoFilterIndex >= _videoFilters.count)
        {
            _videoFilterIndex = 0;
        }
    }
    NSString *code = [_videoFilters objectAtIndex:_videoFilterIndex];
    [self switchFilter:code];
    NSString *key = [NSString stringWithFormat:@"lsq_filter_%@", code];
    [[TuSDK shared].messageHub showToast:NSLocalizedString(key, @"")];
}
- (void)updateShowStatus:(BOOL)isRunning
{
    NSString *imageName = isRunning ? @"icon_pause" : @"icon_play";
    UIImage *image = [UIImage imageNamed:imageName];
    [_mActionButton setImage:image forState:UIControlStateNormal];
}
- (void)updateBeautyStatus:(BOOL)isBeautyEnabled
{
    NSString *imageName = isBeautyEnabled ? @"icon_beauty_on" : @"icon_beauty_off";
    UIImage *image = [UIImage imageNamed:imageName];
    [_mFilterButton setImage:image forState:UIControlStateNormal];
    NSString *key = isBeautyEnabled ? @"beauty_on" : @"beauty_off";
    [[TuSDK shared].messageHub showToast:NSLocalizedString(key, @"")];
}
- (void)updateMuteStatus:(BOOL)isMuted
{
    NSString *imageName = isMuted ? @"icon_volume_off" : @"icon_volume_on";
    
    UIImage *image = [UIImage imageNamed:imageName];
    [_mMuteButton setImage:image forState:UIControlStateNormal];
}
- (void)updateFlashModeStatus
{
    NSString *imageName = @"";
    if (_flashModeIndex == 2)
    {
        imageName = @"icon_flash_auto";
    }
    else if(_flashModeIndex == 1)
    {
        imageName = @"icon_flash_on";
    }
    else
    {
        imageName = @"icon_flash_off";
    }
    UIImage *image = [UIImage imageNamed:imageName];
    [_mFlashButton setImage:image forState:UIControlStateNormal];
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
@end
