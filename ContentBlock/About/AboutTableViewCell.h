//
//  AboutTableViewCell.h
//  AdBlock
//
//  Created by Tommy on 2019/5/21.
//  Copyright © 2019 Tommy. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface AboutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *wordLab;

@property (nonatomic, strong) NSString *word;
@end

NS_ASSUME_NONNULL_END
