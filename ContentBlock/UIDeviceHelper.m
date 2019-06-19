//
//  UIDeviceHelper.m
//  UnlimitedAdsBlock
//
//  Created by a on 27/03/19.
//  Copyright © 2019 TMS. All rights reserved.
//

#import "UIDeviceHelper.h"
#import <sys/utsname.h>

@implementation UIDeviceHelper
- (Model)getDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSDictionary *deviceNamesByCode = nil;
    
    if(! deviceNamesByCode) {
        deviceNamesByCode = @{@"i386"      : @(simulator),
                              @"x86_64"    : @(simulator),
                              //iPod
                              @"iPod1,1"   : @(iPod1),
                              @"iPod2,1"   : @(iPod2),
                              @"iPod3,1"   : @(iPod3),
                              @"iPod4,1"   : @(iPod4),
                              @"iPod5,1"   : @(iPod5),
                              //iPad
                              @"iPad2,1"   : @(iPad2),
                              @"iPad2,2"   : @(iPad2),
                              @"iPad2,3"   : @(iPad2),
                              @"iPad2,4"   : @(iPad2),
                              @"iPad3,1"   : @(iPad3),
                              @"iPad3,2"   : @(iPad3),
                              @"iPad3,3"   : @(iPad3),
                              @"iPad3,4"   : @(iPad4),
                              @"iPad3,5"   : @(iPad4),
                              @"iPad3,6"   : @(iPad4),
                              @"iPad4,1"   : @(iPadAir),
                              @"iPad4,2"   : @(iPadAir),
                              @"iPad4,3"   : @(iPadAir),
                              @"iPad5,3"   : @(iPadAir2),
                              @"iPad5,4"   : @(iPadAir2),
                              @"iPad6,11"  : @(iPad5),
                              @"iPad6,12"  : @(iPad5),
                              @"iPad7,5"   : @(iPad6),
                              @"iPad7,6"   : @(iPad6),
                              //iPad mini
                              @"iPad2,5"   : @(iPadMini),
                              @"iPad2,6"   : @(iPadMini),
                              @"iPad2,7"   : @(iPadMini),
                              @"iPad4,4"   : @(iPadMini2),
                              @"iPad4,5"   : @(iPadMini2),
                              @"iPad4,6"   : @(iPadMini2),
                              @"iPad4,7"   : @(iPadMini3),
                              @"iPad4,8"   : @(iPadMini3),
                              @"iPad4,9"   : @(iPadMini3),
                              @"iPad5,1"   : @(iPadMini4),
                              @"iPad5,2"   : @(iPadMini4),
                              //iPad pro
                              @"iPad6,3"   : @(iPadPro9_7),
                              @"iPad6,4"   : @(iPadPro9_7),
                              @"iPad7,3"   : @(iPadPro10_5),
                              @"iPad7,4"   : @(iPadPro10_5),
                              @"iPad6,7"   : @(iPadPro12_9),
                              @"iPad6,8"   : @(iPadPro12_9),
                              @"iPad7,1"   : @(iPadPro2_12_9),
                              @"iPad7,2"   : @(iPadPro2_12_9),
                              //iPhone
                              @"iPhone3,1" : @(iPhone4),
                              @"iPhone3,2" : @(iPhone4),
                              @"iPhone3,3" : @(iPhone4),
                              @"iPhone4,1" : @(iPhone4S),
                              @"iPhone5,1" : @(iPhone5),
                              @"iPhone5,2" : @(iPhone5),
                              @"iPhone5,3" : @(iPhone5C),
                              @"iPhone5,4" : @(iPhone5C),
                              @"iPhone6,1" : @(iPhone5S),
                              @"iPhone6,2" : @(iPhone5S),
                              @"iPhone7,1" : @(iPhone6plus),
                              @"iPhone7,2" : @(iPhone6),
                              @"iPhone8,1" : @(iPhone6S),
                              @"iPhone8,2" : @(iPhone6Splus),
                              @"iPhone8,4" : @(iPhoneSE),
                              @"iPhone9,1" : @(iPhone7),
                              @"iPhone9,3" : @(iPhone7),
                              @"iPhone9,2" : @(iPhone7plus),
                              @"iPhone9,4" : @(iPhone7plus),
                              @"iPhone10,1" : @(iPhone8),
                              @"iPhone10,4" : @(iPhone8),
                              @"iPhone10,2" : @(iPhone8plus),
                              @"iPhone10,5" : @(iPhone8plus),
                              @"iPhone10,3" : @(iPhoneX),
                              @"iPhone10,6" : @(iPhoneX),
                              @"iPhone11,2" : @(iPhoneXS),
                              @"iPhone11,4" : @(iPhoneXSMax),
                              @"iPhone11,6" : @(iPhoneXSMax),
                              @"iPhone11,8" : @(iPhoneXR),
                              //AppleTV
                              @"AppleTV5,3" : @(AppleTV),
                              @"AppleTV6,2" : @(AppleTV_4K)};
    }
    
    Model modelID = [deviceNamesByCode objectForKey:code]==nil ? unrecognized : (Model)[[deviceNamesByCode objectForKey:code] integerValue];
    
    if(modelID == NSNotFound)
        return unrecognized;
    
    return modelID;
}
@end
