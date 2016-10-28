#import "ViewController.h"
#import "KSYTTDemoVC.h"


#pragma mark - protocol
@protocol DemoChooseDelegate <NSObject>
- (void)onDemoChooseWithIndex:(NSInteger)index;
@end

#pragma mark - DemoRootView
@interface DemoRootView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    TuSDKICTableView *_tableView;
    NSString         *_cellIdentifier;
    NSArray          *_demos;
}

@property (nonatomic, assign) id<DemoChooseDelegate>delegate;
@end
@implementation DemoRootView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self lsqInitView];
    }
    return self;
}
//override
- (void)lsqInitView{
    _cellIdentifier = @"ViewCellIdentify";
    _demos = @[ @"金山demo(未完成)",@"图途demo"];
    _tableView = [TuSDKICTableView table];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.allowsMultipleSelection = NO;
    [self addSubview:_tableView];
}
- (CGFloat)taleView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (self.delegate) {
        [self.delegate onDemoChooseWithIndex:indexPath.row];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _demos.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TuSDKICTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (!cell) {
        cell = [TuSDKICTableViewCell initWithReuseIdentifier:_cellIdentifier];
    }
    cell.textLabel.font = lsqFontSize(15);
    cell.textLabel.text = _demos[indexPath.row];
    return cell;
}
@end
#pragma mark - viewController
@interface ViewController ()<DemoChooseDelegate>
@property (nonatomic, retain) DemoRootView *view;
@end
@implementation ViewController
@dynamic view;

- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)loadView{
    [super loadView];
    self.wantsFullScreenLayout = YES;
    [self setNavigationBarHidden:YES animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [DemoRootView initWithFrame:self.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.delegate = self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"金山demo"];
}
- (void)onDemoChooseWithIndex:(NSInteger)index{
    switch (index) {
        case 0:
            [self openKSYDemo];
            break;
        case 1:
            [self openTTDemo];
            break;
        default:
            break;
    }
}
- (void)openKSYDemo{
    
}
- (void)openTTDemo{
    KSYTTDemoVC *vc = [KSYTTDemoVC new];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

@end
