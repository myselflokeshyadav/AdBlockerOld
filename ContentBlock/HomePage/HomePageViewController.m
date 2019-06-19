//
//  HomePageViewController.m
//  AdBlock
//
//  Created by Tommy on 2019/5/21.
//  Copyright © 2019 Tommy. All rights reserved.
//
#import "AdsModel.h"
#import "UIDeviceHelper.h"
#import "HomePageViewController.h"
#import "HalpViewController.h"
#import "AboutViewController.h"
#import "ImageAdsViewController.h"
#import <SafariServices/SafariServices.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Reachability/Reachability.h>
#import <AFNetworking/AFNetworking.h>
#import "SVProgressHUD.h"
@interface HomePageViewController ()<GADBannerViewDelegate, GADInterstitialDelegate>
@property (weak, nonatomic) IBOutlet UIView *BottomView;
@property (weak, nonatomic) IBOutlet UIView *oneV;
@property (weak, nonatomic) IBOutlet UIView *twoV;
@property (weak, nonatomic) IBOutlet UIView *threeV;
@property (weak, nonatomic) IBOutlet UIImageView *icon_img;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UISwitch *adSwitch;


@end

@implementation HomePageViewController{
    IBOutlet GADBannerView *viewAds;
    IBOutlet UIImageView *imgAds;
    IBOutlet UILabel *lblAds;
    PJGWave *fyjWave;
    NSInteger flag;
    
    ImageAdsViewController *imageAdsViewController;
    GADInterstitial *gadInterstitial;
    NSMutableArray<AdsModel *> *adsModel;
    Reachability *reachability;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    fyjWave.frame = CGRectMake(0, _BottomView.frame.origin.y-fyjWave.bounds.size.height, kDeviceWidth, fyjWave.bounds.size.height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getAds];
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
    
    //Check internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:reachability];
    @try {
        [reachability startNotifier];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    } @finally {
        
    }
}

- (void)getData:(NSURL *)url completion:(void(^)(NSData *, NSURLResponse*, NSError*))completion {
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:completion] resume];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *tempReachability = ((Reachability *) note.object);
    
    switch ([tempReachability currentReachabilityStatus]) {
        case NotReachable:
            [self noInternetConnection];
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            if(adsModel == nil)
                [self getAds];
            break;
    }
}

- (void)noInternetConnection {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Information" message:@"No Internet Connection" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if([self->reachability currentReachabilityStatus] == NotReachable)
            [self noInternetConnection];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)getRatio {
    Model model = [[UIDeviceHelper new] getDevice];
    
    switch(model) {
        case iPhoneXSMax:
        iPhoneXS:
        iPhoneX:
        iPhone8plus:
        iPhone7plus:
        iPhone6plus:
        iPhone6Splus:
            return @"3";
        default:
            return @"2";
    }
}


- (void)getAds {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [manager POST:@"http://47.75.13.70/advertising/ReqAppAd.php"
       parameters:@{@"bundle_id" : [NSBundle mainBundle].bundleIdentifier,
                    @"device" : (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"iphone" : @"ipad"),
                    @"img_size" : [self getRatio],
                    @"version" : appVersion}
         progress:^(NSProgress *_Nonnull uploadProgress) {
             
         }
          success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
              NSError *error;
              NSDictionary *rootJSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
              NSDictionary *json = [rootJSON objectForKey:@"advertise"];
              
              if(json != nil) {
                  self->adsModel = [NSMutableArray new];
                  
                  for(NSDictionary *tempJSON in json) {
                      BOOL isContinueProcess = NO;
                      
                      if([tempJSON objectForKey:@"id"] != nil && [[tempJSON objectForKey:@"id"] integerValue] >= 0)
                          isContinueProcess = true;
                      
                      if(isContinueProcess) {
                          AdsModel *tempAdsModel = [AdsModel new];
                          
                          if([tempJSON objectForKey:@"id"])
                              tempAdsModel.ID = [[tempJSON objectForKey:@"id"] integerValue];
                          
                          if([tempJSON objectForKey:@"seq_number"])
                              tempAdsModel.seqNumber = [[tempJSON objectForKey:@"seq_number"] integerValue];
                          
                          if([tempJSON objectForKey:@"url"])
                              tempAdsModel.url = tempJSON[@"url"];
                          
                          if([tempJSON objectForKey:@"image_url"])
                              tempAdsModel.imageURL = tempJSON[@"image_url"];
                          
                          if([tempJSON objectForKey:@"is_open"])
                              tempAdsModel.isOpen = [[tempJSON objectForKey:@"is_open"] integerValue]==1? true:false;
                          
                          if(tempJSON[@"add_times"])
                              tempAdsModel.addTimes = [tempJSON[@"add_times"] integerValue];
                          
                          if(tempJSON[@"disabled_close"])
                              tempAdsModel.disabledClose = [tempJSON[@"disabled_close"] integerValue];
                          
                          if(tempJSON[@"type"]) {
                              tempAdsModel.type = tempJSON[@"type"];
                              
                              if([tempAdsModel.type isEqualToString:@"native"] && tempAdsModel.isOpen) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      self->viewAds.adUnitID = tempAdsModel.url;
                                      self->viewAds.delegate = self;
                                      self->viewAds.rootViewController = self;
                                      
                                      GADRequest *gadRequest = [GADRequest new];
                                      gadRequest.testDevices = @[ kGADSimulatorID ];
                                      [self->viewAds loadRequest:gadRequest];
                                      self->viewAds.hidden = YES;
                                      self->viewAds.hidden = NO;
                                  });
                              }
                              else if([tempAdsModel.type isEqualToString:@"common"] && tempAdsModel.isOpen && tempAdsModel.url!=nil) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      self->lblAds.hidden = YES;
                                      self->viewAds.hidden = YES;
                                      self->imgAds.hidden = NO;
                                      
                                      NSString *lastPath = tempAdsModel.imageURL.lastPathComponent;
                                      NSArray *arr = [lastPath componentsSeparatedByString:@"id="];
                                      NSString *strFile = [NSTemporaryDirectory() stringByAppendingString:arr[1]];
                                      NSURL *urlFile = [NSURL fileURLWithPath:strFile];
                                      NSFileManager *fileManager = [NSFileManager defaultManager];
                                      
                                      if([fileManager fileExistsAtPath:strFile])
                                          self->imgAds.image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingString:arr[1]]];
                                      else
                                          self->imgAds.image = [UIImage imageNamed:@"banner"];
                                      
                                      NSURL *url = [NSURL URLWithString:tempAdsModel.imageURL];
                                      if(url)
                                          [self getData:url completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if(data && error==nil) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      self->imgAds.image = [UIImage imageWithData:data];
                                                  });
                                                  
                                                  [data writeToURL:urlFile options:NSDataWritingAtomic error:&error];
                                                  
                                                  if(error)
                                                      NSLog(@"%@", error.localizedDescription);
                                              }
                                          }];
                                  });
                              }
                              else if([tempAdsModel.type isEqualToString:@"custom"] && tempAdsModel.isOpen && tempAdsModel.url!=nil) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if(self->gadInterstitial == nil) {
                                          self->gadInterstitial = [[GADInterstitial alloc] initWithAdUnitID:tempAdsModel.url];
                                          self->gadInterstitial.delegate = self;
                                          
                                          
                                          GADRequest *gadRequest = [GADRequest new];
                                          gadRequest.testDevices = @[ kGADSimulatorID ];
                                          [self->gadInterstitial loadRequest:gadRequest];
                                      }
                                  });
                              }
                              else if([tempAdsModel.type isEqualToString:@"special"] && tempAdsModel.isOpen && tempAdsModel.url!=nil) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if(self->imageAdsViewController == nil) {
                                          self->imageAdsViewController = [ImageAdsViewController new];
                                          self->imageAdsViewController.adsModel = tempAdsModel;
                                          [self presentViewController:self->imageAdsViewController animated:YES completion:nil];
                                      }
                                  });
                              }
                          }
                          
                          
                          if(tempJSON[@"desc"])
                              tempAdsModel.desc = tempJSON[@"desc"];
                          [self->adsModel addObject:tempAdsModel];
                      }
                  }
              }
          }
          failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error){
              NSLog(@"%@", error.localizedDescription);
          }];
}

#pragma mark --safari 广告拦截是否开启
- (void)tap:(UITapGestureRecognizer *)tapGesture{
    
    if(flag==0){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Please open Settings -> Safari -> Content Blockers -> Enable AdBlock.Set it up quickly and start intercep-ting advertisements!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"View tutorial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //safari未开启情况下，点击跳转至帮助页面
            HalpViewController *halpVC = [[HalpViewController alloc] init];
            [self presentViewController:halpVC animated:YES completion:nil];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
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
    
    fyjWave = [[PJGWave alloc] initWithFrame:CGRectMake(0, kDeviceHeight-280, kDeviceWidth, 30)];
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
    NSString *textToShare = @"西风";
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
    
    [SVProgressHUD show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
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

#pragma MARK - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if(ad.isReady)
        [ad presentFromRootViewController:self];
}


#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    lblAds.hidden = YES;
}

@end
