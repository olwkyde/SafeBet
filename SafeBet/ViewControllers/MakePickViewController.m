//
//  MakePickViewController.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import "MakePickViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MakePickViewController ()

@property (nonatomic, assign) double betAmountInt;
@property (nonatomic, assign) double teamCorrectInt;

@end

@implementation MakePickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //set up the Bet Text Field
    self.betTextField.layer.borderWidth = 0.3;
    self.betTextField.layer.cornerRadius = 5;
    self.betTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.team1ImageView.layer.cornerRadius = (self.team1ImageView.frame.size.width / 2);
    self.team1ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.team2ImageView.layer.cornerRadius = (self.team2ImageView.frame.size.width / 2);
    self.team1ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self configure];
}
- (IBAction)submitButtonPressed:(id)sender {
}


//sets the labels to their respective text
-(void) configure   {
    self.team1Label.text = self.event.team1;
    self.team2Label.text = self.event.team2;
    NSString *odds1 = [NSString stringWithFormat:@"%d", self.event.team1Odds];
    NSString *odds2 = [NSString stringWithFormat:@"%d", self.event.team2Odds];
    
    
    //adding plus sign to positive odds
    if (([odds1 characterAtIndex:0] == 45)) {
        self.odds1Label.text = odds1;
    }   else{
        self.odds1Label.text = [@"+" stringByAppendingString:odds1];
    }
    if (([odds2 characterAtIndex:0] == 45)) {
        self.odds2Label.text = odds2;
    }   else{
        self.odds2Label.text = [@"+" stringByAppendingString:odds2];
    }
}
- (IBAction)didTapTeam1:(id)sender {
    //check if the bet text field is empty
    self.teamBetOnImageView.image = self.team1ImageView.image;
    self.team1ImageView.layer.borderWidth = 0.3;
    self.team2ImageView.layer.borderWidth = 0;
    
    
}

- (IBAction)didTapTeam2:(id)sender {
    self.teamBetOnImageView.image = self.team2ImageView.image;
    self.team2ImageView.layer.borderWidth = 0.3;
    self.team1ImageView.layer.borderWidth = 0;
}

- (IBAction)viewTapGesture:(id)sender {
    //checking if the bet text field is empty
    [self.view endEditing:true];
    [self updatePayoutInformation];
}

-(void) updatePayoutInformation {
    if (self.betAmountLabel.text != nil)    {
        if ([self.betTextField.text length] != 0 && self.teamBetOnImageView.image != nil) {
            if (self.team1ImageView.layer.borderWidth != 0) {
                self.betAmountInt = [self.betTextField.text intValue];
                if ([self.odds1Label.text characterAtIndex:0] == 45)    {
                    self.teamCorrectInt = (100. / ([[self.odds1Label.text substringFromIndex:1] doubleValue])) * (self.betAmountInt);
                    self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%f", self.teamCorrectInt];
                }   else {
                    self.teamCorrectInt = ([[self.odds1Label.text substringFromIndex:1] doubleValue]) * (self.betAmountInt);
                    self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%f", self.teamCorrectInt];
                }
            }   else if (self.team2ImageView.layer.borderWidth != 0)    {
                    self.betAmountInt = [self.betTextField.text intValue];
                    if ([self.odds2Label.text characterAtIndex:0] == 45)    {
                        self.teamCorrectInt = (100. / ([[self.odds2Label.text substringFromIndex:1] doubleValue])) * (self.betAmountInt);
                        self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%f", self.teamCorrectInt];
                    }   else {
                        self.teamCorrectInt = ([[self.odds2Label.text substringFromIndex:1] doubleValue]) * (self.betAmountInt);
                        self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%f", self.teamCorrectInt];
                }
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
