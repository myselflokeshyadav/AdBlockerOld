//
//  AboutTableViewCell.m
//  AdBlock
//
//  Created by Tommy on 2019/5/21.
//  Copyright © 2019 Tommy. All rights reserved.
//

#import "AboutTableViewCell.h"

@implementation AboutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setWord:(NSString *)word{
    _word = word;
    
    _wordLab.text = word;
    
}

@end
