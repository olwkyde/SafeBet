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
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    self.layer.cornerRadius = 5;
    self.team1ImageView.layer.cornerRadius = (self.team1ImageView.frame.size.width / 2);
    self.team2ImageView.layer.cornerRadius = (self.team2ImageView.frame.size.width / 2);
    self.teamPickedImageView.layer.cornerRadius = (self.teamPickedImageView.frame.size.width /2);
    
    NSString *odds1 = self.team1OddsLabel.text;
    NSString *odds2 = self.team2OddsLabel.text;
    
    if (odds1 != nil && ([odds1 characterAtIndex:0] == 45)) {
        self.team1OddsLabel.text = odds1;
    }   else{
        self.team1OddsLabel.text = [@"+" stringByAppendingString:odds1];
    }
    if (odds2 != nil &&([odds2 characterAtIndex:0] == 45)) {
        self.team2OddsLabel.text = odds2;
    }   else{
        self.team2OddsLabel.text = [@"+" stringByAppendingString:odds2];
    }
}

@end
