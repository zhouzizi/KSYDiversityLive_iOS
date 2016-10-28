#import "ViewController.h"
#import "KSYTestKit.h"
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    KSYTestKit           *_kit;
    NSURL                *_hostURL;
    NSMutableArray       *_resourceArray;
    UILabel              *_notiLabel;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSArray *array = [NSArray arrayWithObjects:@"open",@"kitty.bundle", @"fox.bundle", @"evil.bundle", @"eyeballs.bundle", @"mood.bundle", @"tears.bundle", @"rabbit.bundle", @"cat.bundle", @"close", nil];
    NSArray *array = [NSArray arrayWithObjects:@"open",@"kitty", @"fox", @"evil", @"eyeballs", @"mood", @"tears", @"rabbit", @"cat", @"close", nil];
    _resourceArray = [NSMutableArray arrayWithArray:array];
//    NSString *str = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"v2.bundle"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:str]) {
//        [self loadDataWithItem:@"v2.bundle"];
//    }
//    str = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"ar.bundle"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:str]) {
//        [self loadDataWithItem:@"ar.bundle"];
//    }
    
    _kit = [[KSYTestKit alloc] initWithDefaultCfg];
    
    // 采集相关设置初始化
    [self setCaptureCfg];
    //推流相关设置初始化
    [self setStreamerCfg];
    
    if (_kit) { // init with default filter
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self startCapture:nil];
    }
    [self iniWithUI];
}
- (void)iniWithUI{
    //创建一个
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //设置每个item的大小为100 * 100
    layout.itemSize = CGSizeMake(50, 50);
    //创建collectionview通过一个布局策略来创建
    UICollectionView *collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 100)  collectionViewLayout:layout];
    //设置代理
    collect.delegate = self;
    collect.dataSource = self;
    collect.backgroundColor = [UIColor blackColor];
    collect.alpha = 0.5;
    //组册item类型，这里使用系统的类型
    [collect registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self.view addSubview:collect];
    
    //添加text
    _notiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    _notiLabel.textColor = [UIColor blackColor];
    _notiLabel.text = @"请开启贴纸功能";
    _notiLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_notiLabel];
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *fileName = [_resourceArray objectAtIndex:indexPath.row];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePathWithName:fileName]]) {
//        [self loadDataWithItem:fileName];
//    }
    switch (indexPath.row) {
        case 0:
            _notiLabel.text = @"open";
            [_kit openSticker];
            break;
        case 1:
            _notiLabel.text = @"kitty";
            [_kit selectSticker:1];
            break;
        case 2:
            _notiLabel.text = @"fox";
            [_kit selectSticker:2];
            break;
        case 3:
            _notiLabel.text = @"evil";
            [_kit selectSticker:3];
            break;
        case 4:
            _notiLabel.text = @"eyeballs 请张开嘴";
            [_kit selectSticker:4];
            break;
        case 5:
            _notiLabel.text = @"mood";
            [_kit selectSticker:5];
            break;
        case 6:
            _notiLabel.text = @"tears 请张开嘴";
            [_kit selectSticker:6];
            break;
        case 7:
            _notiLabel.text = @"rabbit";
            [_kit selectSticker:7];
            break;
        case 8:
            _notiLabel.text = @"cat";
            [_kit selectSticker:8];
            break;
        case 9:
            _notiLabel.text = @"close";
            [_kit closeSticker];
            break;
        default:
            break;
    }
}

//返回分区个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}
//获取cell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%@",[_resourceArray objectAtIndex:indexPath.row]];
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:label];
    return cell;
}
- (void)loadDataWithItem:(NSString *)fileName{
    //创建url
    NSString *urlStr = [NSString stringWithFormat:@"http://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/%@",fileName];
    //urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //__weak typeof(self) weakSelf = self;
    //创建会话 这里使用一个全局会话 并启动任务
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            //注意location是下载后的临时保存路径，需要将他移动到需要保存的位置
            NSError *saveError;
            NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *savePath=[cachePath stringByAppendingPathComponent:fileName];
            NSURL *saveUrl = [NSURL fileURLWithPath:savePath];
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&saveError];
            if (!saveError) {
                NSLog(@"save sucess.");
            }else{
                NSLog(@"saveError is :%@",saveError.localizedDescription);
            }
        }else{
            NSLog(@"error is %@", error.localizedDescription);
        }
    }];
    [downloadTask resume];
}
- (NSString *)dataFilePathWithName:(NSString *)name{
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath=[cachePath stringByAppendingPathComponent:name];
    return savePath;
}
#pragma mark - Capture & stream setup
- (void) setCaptureCfg {
    _kit.capPreset        = AVCaptureSessionPresetiFrame960x540;
    _kit.previewDimension = CGSizeMake(640, 480);
    _kit.streamDimension  = CGSizeMake(640, 480);
    _kit.videoFPS         = 30;
    _kit.cameraPosition   = AVCaptureDevicePositionFront;
    _kit.videoProcessingCallback = ^(CMSampleBufferRef buf){
        
    };
}
- (void) setStreamerCfg { // must set after capture
    if (_kit.streamerBase == nil) {
        return;
    }
    [self defaultStramCfg];
}
- (void) defaultStramCfg{
        // stream default settings
        _kit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
        _kit.streamerBase.videoInitBitrate =  800;
        _kit.streamerBase.videoMaxBitrate  = 1000;
        _kit.streamerBase.videoMinBitrate  =    0;
        _kit.streamerBase.audiokBPS        =   48;
        _kit.streamerBase.enAutoApplyEstimateBW     = YES;
        _kit.streamerBase.shouldEnableKSYStatModule = YES;
        _kit.streamerBase.videoFPS = 15;
        _kit.streamerBase.logBlock = ^(NSString* str){
            NSLog(@"%@", str);
        };
    _hostURL = [NSURL URLWithString:@"rtmp://test.uplive.ksyun.com/live/823"];
}
- (IBAction)startCapture:(id)sender {
    if (!_kit.vCapDev.isRunning){
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit startPreview:self.view];
    }
    else {
        [_kit stopPreview];
    }
}

- (IBAction)startStream:(id)sender {
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [_kit.streamerBase startStream:_hostURL];
    }
    else {
        [_kit.streamerBase stopStream];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
