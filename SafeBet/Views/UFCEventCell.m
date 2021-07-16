//
//  UFCEventCell.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/15/21.
//

#import "UFCEventCell.h"

@implementation UFCEventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setUpViews];
    [self setUpConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

}

- (void) setUpViews {
    self.dayLabel = [[UILabel alloc] init];
    self.dayLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.dayLabel.textColor = [UIColor whiteColor];
    [self.dayLabel.font fontWithSize:17];
    [self addSubview:self.dayLabel];
    
    self.team1Label = [[UILabel alloc] init];
    self.team1Label.translatesAutoresizingMaskIntoConstraints = false;
    self.team1Label.textColor = [UIColor whiteColor];
    [self.team1Label.font fontWithSize:17];
    [self addSubview:self.team1Label];
    
    self.team2Label = [[UILabel alloc] init];
    self.team2Label.translatesAutoresizingMaskIntoConstraints = false;
    self.team2Label.textColor = [UIColor whiteColor];
    [self.team2Label.font fontWithSize:17];
    [self addSubview:self.team2Label];
    
    self.team1OddsLabel = [[UILabel alloc] init];
    self.team1OddsLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.team1OddsLabel.textColor = [UIColor whiteColor];
    [self.team1OddsLabel.font fontWithSize:17];
    [self addSubview:self.team1OddsLabel];
    
    self.team2OddsLabel = [[UILabel alloc] init];
    self.team2OddsLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.team2OddsLabel.textColor = [UIColor whiteColor];
    [self.team2OddsLabel.font fontWithSize:17];
    [self addSubview:self.team2OddsLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.timeLabel.font fontWithSize:17];
    [self addSubview:self.timeLabel];
    
    self.separator = [[UIView alloc] init];
    self.separator.translatesAutoresizingMaskIntoConstraints = false;
    self.separator.backgroundColor = [UIColor grayColor];
    
    [self addSubview:self.separator];
}


-(void) setUpConstraints    {
    [self.team1Label.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:15].active = YES;
    [self.team1Label.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15].active = YES;
    
    [self.team2Label.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:15].active = YES;
    [self.team2Label.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15].active = YES;
    
    [self.team1OddsLabel.leadingAnchor constraintEqualToAnchor:self.team1Label.trailingAnchor constant:10].active = YES;
    [self.team1OddsLabel.centerYAnchor constraintEqualToAnchor:self.team1Label.centerYAnchor].active = YES;
    
    [self.team2OddsLabel.leadingAnchor constraintEqualToAnchor:self.team2Label.trailingAnchor constant:15].active = YES;
    [self.team2OddsLabel.centerYAnchor constraintEqualToAnchor:self.team2Label.centerYAnchor].active = YES;

    [self.separator.widthAnchor constraintEqualToConstant:1].active = YES;
    [self.separator.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:100].active = YES;
    [self.separator.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5].active = YES;
    [self.separator.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:5].active = YES;
    
    [self.dayLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:43].active = YES;
    [self.dayLabel.leadingAnchor constraintEqualToAnchor:self.separator.trailingAnchor constant:10].active = YES;
    
    [self.timeLabel.topAnchor constraintEqualToAnchor:self.dayLabel.bottomAnchor constant:8].active = YES;
    [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.dayLabel.leadingAnchor].active = YES;
}

@end
