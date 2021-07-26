//
//  MakePickViewController.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import <UIKit/UIKit.h>
#import "Events.h"
#import "Bet.h"

NS_ASSUME_NONNULL_BEGIN

@interface MakePickViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UIImageView *team1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *team2ImageView;
@property (weak, nonatomic) IBOutlet UIButton *team1Button;
@property (weak, nonatomic) IBOutlet UIButton *team2Button;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) NSDate *gameDay;
@property (weak, nonatomic) IBOutlet UILabel *team1Label;
@property (weak, nonatomic) IBOutlet UILabel *team2Label;
@property (weak, nonatomic) IBOutlet UILabel *odds1Label;
@property (weak, nonatomic) IBOutlet UILabel *odds2Label;
@property (weak, nonatomic) IBOutlet UITextField *betTextField;
@property (weak, nonatomic) IBOutlet UILabel *bankAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *betAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamCorrectAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *payoutAmountLabel;
@property (nonatomic, strong) UIImageView *teamBetOnImageView;
@property (nonatomic, assign) double payoutInt;
@property (strong, nonatomic) Events *event;
@property (strong, nonatomic) Bet *bet;

@end

NS_ASSUME_NONNULL_END
