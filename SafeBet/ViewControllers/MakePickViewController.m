//
//  MakePickViewController.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import "MakePickViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Lottie/Lottie.h>
#import "Bet.h"
#import <Parse/Parse.h>

@interface MakePickViewController ()

@property (nonatomic, assign) double betAmountInt;
@property (nonatomic, assign) double teamCorrectInt;
@property (weak, nonatomic) IBOutlet UIView *animationView;
@property (nonatomic, assign) double bankAmount;

@end

@implementation MakePickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpViews];
    [self configureLabels];
}

// sets up attributes of some of the main views
- (void) setUpViews {
    //set up the Bet Text Field
    self.betTextField.layer.borderWidth = 0.3;
    self.betTextField.layer.cornerRadius = 5;
    self.betTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //set up the Buttons for each team Image
    self.team1Button.layer.cornerRadius = (self.team1Button.frame.size.width / 2);
    self.team1Button.layer.borderColor = [UIColor whiteColor].CGColor;
    self.team2Button.layer.cornerRadius = (self.team2Button.frame.size.width / 2);
    self.team2Button.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //rounded corners for the submit button
    self.submitButton.layer.cornerRadius = 5;
    
    self.bankAmount = [[PFUser.currentUser objectForKey:@"bank"] doubleValue];
    
    self.bankAmountLabel.text = [@"Bank: $" stringByAppendingString:[NSString stringWithFormat:@"%.2f", self.bankAmount]];
}

//action to perform if team1 is tapped
- (IBAction)didTapTeam1Button:(id)sender {
    //self.teamBetOnImageView.image = self.team1Button.imageView.image;
    
    //change the color of the team
    self.team1Label.textColor = [UIColor greenColor];
    self.team2Label.textColor = [UIColor whiteColor];
    
        
    //add a green color to indicate the team has been selected
    if ([self.betTextField.text length] != 0)   {
        [self updatePayoutInformation];
    }
}

//check if team 1 was selected
-(BOOL)team1Selected    {
    return (self.team1Label.textColor == [UIColor greenColor]);
}

//action performed if team2Button is tapped
- (IBAction)didTapTeam2Button:(id)sender {
    //self.teamBetOnImageView.image = self.team2Button.imageView.image;
    
    //add a green color to indicate the team has been selected
    self.team2Label.textColor = [UIColor greenColor];
    self.team1Label.textColor = [UIColor whiteColor];
    
    //update payout info if the text field is not empty
    if ([self.betTextField.text length] != 0)   {
        [self updatePayoutInformation];
    }
}

//check whether team2 was selected and highlight the text field
-(BOOL)team2Selected    {
    return (self.team2Label.textColor == [UIColor greenColor]);
}

- (IBAction)submitButtonPressed:(id)sender {
    //create a UIAlertController
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"  message:@"You must pick a team and have a bet amount." preferredStyle:(UIAlertControllerStyleAlert)];
    // create a ok action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
    //add the ok action to the alert
    [alert addAction:okAction];
    
    
    
    //checks if the bet field is empty, 0, or either team isn't selected
    if (([self.betTextField.text length] == 0 || ([self.betTextField.text doubleValue] == 0.0) ) || !([self team1Selected] || [self team2Selected])) {
        // present the alert controller
        [self presentViewController:alert animated:YES completion:^{
            // optional code for what happens after the alert controller has finished presenting
        }];
    }
    //show error if bet exceeds the bank
    else if (self.betAmountInt >= self.bankAmount)  {
        self.bankAmountLabel.textColor = [UIColor redColor];
        [alert setMessage:@"Your bet amount cannot exceed your bank"];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
    
    else{
        if (self.bet != nil)   {
            UIAlertController *warning = [UIAlertController alertControllerWithTitle:@"Warning"  message:@"" preferredStyle:(UIAlertControllerStyleAlert)];
            NSString *betPickOdds = ([self team1Selected])? self.odds1Label.text: self.odds2Label.text;
            [warning setMessage:[@"Would you like to edit pick of " stringByAppendingFormat:@"%@ %@ %@ %@ %.2f %@", self.bet.betPick, @" @ ", betPickOdds, @"for $", self.bet.betAmount, @"?"]];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
            //add the cancel action to the alert
            [warning addAction:cancelAction];
            // create a ok action
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self updatePayoutInformation];
                self.bankAmountLabel.textColor = [UIColor whiteColor];
                
                //delete the bet
                [self.bet deleteBet];
                
                //update the bank label
                self.bankAmountLabel.text = [@"Bank : $" stringByAppendingFormat:@"%.2f",([[PFUser.currentUser objectForKey:@"bank"] doubleValue])+ self.bet.betAmount - self.betAmountInt];
                
                [self playAnimation];
                [self.navigationController popViewControllerAnimated:YES];
                }];
            
            //add the ok action to the alert
            [warning addAction:okAction];
            
            [self presentViewController:warning animated:YES completion:^{
            }];
        }
        else    {
            [self updatePayoutInformation];
            [self playAnimation];
        }
    }
}

//plays a success animation
-(void) playAnimation   {
    //create an animation
    LOTAnimationView *animation = [LOTAnimationView animationNamed:@"success"];
    [self.view addSubview:animation];
    [animation setFrame:self.animationView.frame];
    [animation playWithCompletion:^(BOOL animationFinished) {
        //make a new Bet
        Bet *bet = [[Bet alloc] init];
        bet.payout = self.payoutInt;
        
        self.bankAmountLabel.textColor = [UIColor whiteColor];
        
        //update the bank label (if it hasn't already been done)
        if (self.bet == nil)    {self.bankAmountLabel.text = [@"Bank: $" stringByAppendingString:[NSString stringWithFormat:@"%.2f", (self.bankAmount - self.betAmountInt)]];}
        
        //update the bank Amount
        self.bankAmount = [[PFUser.currentUser valueForKey:@"bank"] doubleValue];
        
        //set the new bank amount in Parse
        [PFUser.currentUser setValue:[NSNumber numberWithDouble:(self.bankAmount - self.betAmountInt + self.bet.betAmount)] forKey:@"bank"];
        
        //increment number of bets made
        int betsMade = ([[PFUser.currentUser objectForKey:@"betsMade"] intValue]) + 1;
        [PFUser.currentUser setValue:[NSNumber numberWithInt:betsMade] forKey:@"betsMade"];
        
        NSString *teamSelected = [[NSString alloc] init];
        if ([self team1Selected]) {
            teamSelected = self.team1Label.text;
        } else {
            teamSelected = self.team2Label.text;
        }
        
        //post the Bet
        [Bet postBetWithEvent:self.event withBetAmount:self.betAmountInt withBetPick:teamSelected withCompletion:nil];
        
        [self.delegate madeBet:bet];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

//configures odds so that underdogs get the '+' symbol in front of the odds (an underdog can have +100 odds)
- (NSString *) configureOdds: (nonnull int *) odd{
    NSString *oddString = [NSString stringWithFormat:@"%d", odd];
    if ((([oddString characterAtIndex:0] == 45) || ([oddString characterAtIndex:0] == 43 && [oddString intValue] != 0))) {
        return oddString;
    }   else{
        return [@"+" stringByAppendingString:oddString];
    }
}

//sets the labels to their respective text
-(void) configureLabels   {
    self.team1Label.text = self.event.team1;
    self.team2Label.text = self.event.team2;
    [self.team1Button setImage:self.event.team1Image.image forState:UIControlStateNormal];
    [self.team2Button setImage:self.event.team2Image.image forState:UIControlStateNormal];

    
    //adding plus sign to positive odds
    self.odds1Label.text = [self configureOdds:self.event.team1Odds];
    self.odds2Label.text = [self configureOdds:self.event.team2Odds];

    
    self.gameDay = self.event.gameDate;
    
    //already have the bet amount in the view controller
    if (self.bet != nil)    {
        self.betTextField.text = [NSString stringWithFormat:@"%.2f", self.bet.betAmount];
        if ([self.bet.betPick isEqualToString:self.bet.team1])   {
            self.team1Label.textColor = [UIColor greenColor];
        }   else    {
            self.team2Label.textColor = [UIColor greenColor];
        }
    }
}

//action to occur when the view is tapped
- (IBAction)viewTapGesture:(id)sender {
    //dismiss the keyboard
    [self.view endEditing:true];
    
    //check if the bet text field is empty and if a team has been selected and update payout information if so
    if ([self.betTextField.text length] != 0 && ([self team1Selected] || [self team2Selected])) {
        [self updatePayoutInformation];
    }
}

//updates the bet, team correct, and payout information based on the bet amount placed and team it is bet on
-(void) updatePayoutInformation {
    //set bet amount and display it
    self.betAmountInt = [self.betTextField.text doubleValue];
    self.betAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.betAmountInt];
    
    if ([self team1Selected])   {
        //check whether team1 odds are negative and calculate the payout accordingly
        if ([self.odds1Label.text characterAtIndex:0] == 45)    {
            self.teamCorrectInt = (100. / ([[self.odds1Label.text substringFromIndex:1] doubleValue])) * (self.betAmountInt);
            self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.teamCorrectInt];
            
            self.payoutInt = self.betAmountInt + self.teamCorrectInt;
            self.payoutAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.payoutInt];
        }   else {
                self.teamCorrectInt = ([[self.odds1Label.text substringFromIndex:1] doubleValue] / 100.) * (self.betAmountInt);
                self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.teamCorrectInt];
            
                self.payoutInt = self.betAmountInt + self.teamCorrectInt;
                self.payoutAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.payoutInt];
            }
    }   else    {
            if ([self.odds2Label.text characterAtIndex:0] == 45)    {
                self.teamCorrectInt = (100. / ([[self.odds2Label.text substringFromIndex:1] doubleValue])) * (self.betAmountInt);
                self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.teamCorrectInt];
                
                self.payoutInt = self.betAmountInt + self.teamCorrectInt;
                self.payoutAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.payoutInt];
            }   else {
                    self.teamCorrectInt = ([[self.odds2Label.text substringFromIndex:1] doubleValue] / 100.) * (self.betAmountInt);
                    self.teamCorrectAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.teamCorrectInt];
                
                    self.payoutInt = self.betAmountInt + self.teamCorrectInt;
                    self.payoutAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.payoutInt];
            }
    }
}
@end
