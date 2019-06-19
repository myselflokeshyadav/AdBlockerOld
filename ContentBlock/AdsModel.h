//
//  AdsModel.h
//  UnlimitedAdsBlock
//
//  Created by a on 26/03/19.
//  Copyright © 2019 TMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdsModel : NSObject
@property (nonatomic) BOOL isOpen;
@property (nonatomic) NSInteger ID;
@property (nonatomic) NSInteger seqNumber;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *imageURL;
@property (nonatomic) NSInteger addTimes;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *desc;
@property (nonatomic) NSInteger disabledClose;
@end
