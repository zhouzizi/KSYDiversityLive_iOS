#import <UIKit/UIKit.h>
#import "KSYTTBaseVC.h"
#import "KSYCameraSource.h"
#import <libksygpulive/libksygpulive.h>

@interface KSYTTDemoVC : KSYTTBaseVC

@property(nonatomic, strong) KSYCameraSource     *cameraSource;
@property(nonatomic, strong) KSYStreamerBase     *streamerBase;
@property(nonatomic, strong) KSYAUAudioCapture   *audioCapDev;
@property(nonatomic, strong) KSYAudioMixer       *aMixer;
@property(nonatomic, assign) int                 micTrack;
@end

