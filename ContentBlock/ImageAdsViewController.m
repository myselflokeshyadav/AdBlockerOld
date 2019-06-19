//
//  ImageAdsViewController.m
//  
//
//  Created by a on 26/03/19.
//  Copyright © 2019 TMS. All rights reserved.
//
#import "AdsModel.h"
#import "AppDelegate.h"
#import "ImageAdsViewController.h"

@interface ImageAdsViewController ()

@end

@implementation ImageAdsViewController {
    UIImageView *imgAds;
    UIButton *btnClose;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    if(_adsModel.imageURL != nil) {
        NSString *lastPath = _adsModel.imageURL.lastPathComponent;
        NSArray *arr = [lastPath componentsSeparatedByString:@"id="];
        NSString *strFile = [NSTemporaryDirectory() stringByAppendingString:arr[1]];
        NSURL *urlFile = [NSURL fileURLWithPath:strFile];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:strFile])
            imgAds.image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingString:arr[1]]];
        else {
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                imgAds.image = [UIImage imageNamed:@"ipad_banner"];
            else
                imgAds.image = [UIImage imageNamed:@"iphone_banner"];
        }

        [self getData:[NSURL URLWithString:_adsModel.imageURL] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(data && error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->imgAds.image = [UIImage imageWithData:data];
                    [data writeToURL:urlFile options:NSDataWritingAtomic error:nil];
                });
            }
        }];
    }
    
    imgAds.userInteractionEnabled = YES;
    [imgAds addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actImage:)]];
    btnClose.hidden = _adsModel.disabledClose==1;
}


- (void)setupView {
    CGFloat topSpace = 0;
    if(@available(iOS 11.0, *)) {
        UIWindow *window = ((AppDelegate *) [UIApplication sharedApplication].delegate).window;
        topSpace = window.safeAreaInsets.top;
    }

    self.view.backgroundColor = [UIColor whiteColor];
    imgAds = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    imgAds.contentMode = UIViewContentModeScaleAspectFit;

    btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(0, topSpace + 20, 44, 44);
    btnClose.titleLabel.font = [UIFont fontWithName:@"GillSans" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 20:30];
    [btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnClose setTitle:@"X" forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(actClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imgAds];
    [self.view addSubview:btnClose];
    
    
}

- (void)getData:(NSURL *)url completion:(void(^)(NSData *, NSURLResponse*, NSError*))completion {
    [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:completion];
}


- (void)actImage:(id)sender {
    if(_adsModel.url != nil) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:_adsModel.url]]) {
            if(@available(iOS 10.0, *))
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_adsModel.url] options:@{} completionHandler:nil];
            else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_adsModel.url]];
        }
    }
}

- (void)actClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
