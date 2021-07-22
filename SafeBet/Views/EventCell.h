//
//  EventCell.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import <UIKit/UIKit.h>
#import "Events.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *team1Label;
@property (weak, nonatomic) IBOutlet UIImageView *team1ImageView;
@property (weak, nonatomic) IBOutlet UILabel *team2Label;
@property (weak, nonatomic) IBOutlet UIImageView *team2ImageView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *team1OddsLabel;
@property (weak, nonatomic) IBOutlet UILabel *team2OddsLabel;
@property (nonatomic, strong) Events *event;

@end

NS_ASSUME_NONNULL_END
