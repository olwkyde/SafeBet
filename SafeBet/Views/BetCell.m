//
//  BetCell.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/24/21.
//

#import "BetCell.h"

@implementation BetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.layer.cornerRadius = 5;
    self.team1ImageView.layer.cornerRadius = (self.team1ImageView.frame.size.width / 2);
    self.team2ImageView.layer.cornerRadius = (self.team2ImageView.frame.size.width / 2);
    self.teamPickedImageView.layer.cornerRadius = (self.teamPickedImageView.frame.size.width /2);
    
    if ([self.team1OddsLabel.text isEqualToString:@"100"] || [self.team1OddsLabel.text isEqualToString:@"-100"])    {
        self.team1OddsLabel.text = @"+100";
    }
    if ([self.team2OddsLabel.text isEqualToString:@"100"] || [self.team2OddsLabel.text isEqualToString:@"-100"])    {
        self.team2OddsLabel.text = @"+100";
    }
}

@end
