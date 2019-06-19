//
//  UIDeviceHelper.h
//  UnlimitedAdsBlock
//
//  Created by a on 27/03/19.
//  Copyright © 2019 TMS. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    simulator,
    //iPod
    iPod1,
    iPod2,
    iPod3,
    iPod4,
    iPod5,
    //iPad
    iPad2,
    iPad3,
    iPad4,
    iPadAir,
    iPadAir2,
    iPad5,
    iPad6,
    //iPad mini
    iPadMini,
    iPadMini2,
    iPadMini3,
    iPadMini4,
    //iPad pro
    iPadPro9_7,
    iPadPro10_5,
    iPadPro12_9,
    iPadPro2_12_9,
    //iPhone
    iPhone4,
    iPhone4S,
    iPhone5,
    iPhone5S,
    iPhone5C,
    iPhone6,
    iPhone6plus,
    iPhone6S,
    iPhone6Splus,
    iPhoneSE,
    iPhone7,
    iPhone7plus,
    iPhone8,
    iPhone8plus,
    iPhoneX,
    iPhoneXS,
    iPhoneXSMax,
    iPhoneXR,
    //Apple TV
    AppleTV,
    AppleTV_4K,
    unrecognized = NSNotFound
} Model;

@interface UIDeviceHelper : NSObject
@property (nonatomic, getter=getDevice) Model deviceModel;
@end
