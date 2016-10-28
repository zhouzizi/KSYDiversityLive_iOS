#import <UIKit/UIKit.h>
#import <TuSDK/TuSDK.h>
#import <TuSDKVideo/TuSDKVideo.h>

@interface KSYTTBaseVC : UIViewController
{
@protected
    BOOL _muteButtonEnabled;
    BOOL _beautyEnabled;
    NSArray *_videoFilters;
    NSInteger _videoFilterIndex;
}
#pragma mark - property
@property (readonly, nonatomic) UIButton *mActionButton;
@property (readonly, nonatomic) UIButton *mFilterButton;
@property (readonly, nonatomic) UIButton *mToggleCameraButton;
@property (readonly, nonatomic) UIButton *mFlashButton;
@property (readonly, nonatomic) UIButton *mMuteButton;
@property (nonatomic, readonly) UIButton *mSettingButton;
@property (nonatomic, readonly) UIButton *mCloseButton;
@property (nonatomic, readonly) UIButton *startLiveButton;
@property (nonatomic, readwrite) NSInteger flashModeIndex;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
#pragma mark - method
- (void)lsqInitView;
- (void)updateShowStatus:(BOOL)isRunning;
- (void)updateBeautyStatus:(BOOL)isBeautyEnabled;
- (void)updateMuteStatus:(BOOL)isMuted;
- (void)updateFlashModeStatus;
- (void)onConfigButtonClicked:(id)sender;
- (void)onActionHandle:(id)sender;
- (void)switchFilter:(NSString *)code;
- (void)startStream:(UIButton *)btn;
@end
