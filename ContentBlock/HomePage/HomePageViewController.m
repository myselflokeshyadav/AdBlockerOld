//
//  HomePageViewController.m
//  AdBlock
//
//  Created by Tommy on 2019/5/21.
//  Copyright © 2019 Tommy. All rights reserved.
//

#import "HomePageViewController.h"
#import "HalpViewController.h"
#import "AboutViewController.h"
#import <SafariServices/SafariServices.h>
@interface HomePageViewController ()
@property (weak, nonatomic) IBOutlet UIView *BottomView;
@property (weak, nonatomic) IBOutlet UIView *oneV;
@property (weak, nonatomic) IBOutlet UIView *twoV;
@property (weak, nonatomic) IBOutlet UIView *threeV;
@property (weak, nonatomic) IBOutlet UIImageView *icon_img;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UISwitch *adSwitch;


@end

@implementation HomePageViewController{
    
    NSInteger flag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:SWITCHKG];
    if(str.length>0){
        _adSwitch.on = YES;
    }else{
        _adSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SWITCHKG];
    }
    
    [self CreatBottomView];
    [self setLayerView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_icon_img addGestureRecognizer:tap];
    
    
    [SFContentBlockerManager reloadContentBlockerWithIdentifier:APP_EXTENSION_NAME completionHandler:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"RELOAD OF %@ FAILED WITH ERROR -%@", APP_EXTENSION_NAME,[error localizedDescription]);
        }
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleBlockerState)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}
#pragma mark --safari 广告拦截是否开启
- (void)tap:(UITapGestureRecognizer *)tapGesture{
    
    if(flag==0){
        //safari未开启情况下，点击跳转至帮助页面
        HalpViewController *halpVC = [[HalpViewController alloc] init];
        [self presentViewController:halpVC animated:YES completion:nil];
        
    }
    
}
#pragma mark -layer
- (void)setLayerView{
    
    _oneV.layer.cornerRadius = 5;
    _oneV.layer.masksToBounds = YES;
    _twoV.layer.cornerRadius = 5;
    _twoV.layer.masksToBounds = YES;
    _threeV.layer.cornerRadius = 5;
    _threeV.layer.masksToBounds = YES;
    
}
#pragma mark --底部弧度
- (void)CreatBottomView{
    
    PJGWave *fyjWave = [[PJGWave alloc] initWithFrame:CGRectMake(0, kDeviceHeight-280, kDeviceWidth, 30)];
    fyjWave.backgroundColor = [UIColor clearColor];
    fyjWave.waveHeight = 25;
    fyjWave.waveCurve = 0.3;
    fyjWave.waveSpeed = 1;
    fyjWave.realWaveColor = [WaveColor colorWithAlphaComponent:1];
    fyjWave.maskWaveColor = [WaveColor colorWithAlphaComponent:0.5];
    [self.view addSubview:fyjWave];
    
    //2.根据传回的centerY值修改头像的Y坐标
    [fyjWave setWaveFloatYCallBack:^(CGFloat centerY) {
    }];
    
    //3.开始动画
    [fyjWave startWaveAnimation];
    
}
//分享
- (IBAction)shareAction:(id)sender {
    NSString *textToShare = @"AdBlocker";
    NSURL *urlToShare = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8",AppID]];
    NSArray *activityItems = @[textToShare,urlToShare];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    vc.excludedActivityTypes = @[UIActivityTypeAirDrop,UIActivityTypeMessage];
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    };
    vc.completionWithItemsHandler = myBlock;
    vc.popoverPresentationController.sourceView = self.view;
    [self presentViewController:vc animated:YES completion:nil];
}
//帮助
- (IBAction)halpAction:(id)sender {
    HalpViewController *halpVC = [[HalpViewController alloc] init];
    [self presentViewController:halpVC animated:YES completion:nil];
}
//ad开关
- (IBAction)switchAction:(UISwitch *)sender {
    
//    [SVProgressHUD show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [SVProgressHUD dismiss];
        if(sender.on){
            //开启过滤
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SWITCHKG];
        }else{
            //关闭过滤
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SWITCHKG];
        }
    });
    
    
}
//关于我们
- (IBAction)aboutAction:(id)sender {
    
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    [self presentViewController:aboutVC animated:YES completion:nil];
}

- (void)handleBlockerState {
    
    // getStateofContentBlockerIdentifier API is iOS 10 only
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 10, .minorVersion = 0, .patchVersion = 0}]) {
        [SFContentBlockerManager getStateOfContentBlockerWithIdentifier:APP_EXTENSION_NAME completionHandler:^(SFContentBlockerState * _Nullable state, NSError * _Nullable error) {
            if (error!=nil) {
                NSLog(@"GETTING STATE OF %@ FAILED WITH ERROR -%@", APP_EXTENSION_NAME,[error localizedDescription]);
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (state.enabled) { // blocker turned ON in settings
                        //开启广告拦截
                        flag = 1;
                        _icon_img.image = [UIImage imageNamed:@"star"];
                        _contentLab.text = @"Already opened";
                    } else { // blocker turned OFF in settings
                        //关闭广告拦截
                        flag = 0;
                        _icon_img.image = [UIImage imageNamed:@"close"];
                        _contentLab.text = @"Open advertising filtering";
                    }
                });
            }
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
