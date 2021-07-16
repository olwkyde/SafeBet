//
//  UFCEventCell.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "Events.h"

NS_ASSUME_NONNULL_BEGIN

@interface UFCEventCell : UITableViewCell
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *team1Label;
@property (strong, nonatomic) IBOutlet UILabel *team2Label;
@property (strong, nonatomic) IBOutlet UILabel *dayLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *team1OddsLabel;
@property (strong, nonatomic) IBOutlet UILabel *team2OddsLabel;
@property (strong, nonatomic) IBOutlet UIView *separator;
@property (nonatomic, strong) Events *event;
@end

NS_ASSUME_NONNULL_END
