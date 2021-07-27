//
//  EventCell.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import "EventCell.h"

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.layer.cornerRadius = 5;
    self.team1ImageView.layer.cornerRadius = self.team1ImageView.frame.size.width / 2;
    self.team2ImageView.layer.cornerRadius = self.team2ImageView.frame.size.width / 2;
}

@end
