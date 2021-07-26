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
    [self configure];
}

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
    
    self.bankAmountLabel.text = [@"Bank: " stringByAppendingString:[NSString stringWithFormat:@"%.2f", self.bankAmount]];
}

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

-(BOOL)team2Selected    {
    return (self.team2Label.textColor == [UIColor greenColor]);

}

- (IBAction)submitButtonPressed:(id)sender {
    //create a UIAlertController
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"  message:@"You must pick a team and have a bet amount." preferredStyle:(UIAlertControllerStyleAlert)];
    // create a CANCEL action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
    //add the CANCEL action to the alert
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
        [self updatePayoutInformation];
        self.bankAmountLabel.textColor = [UIColor whiteColor];
        self.bankAmountLabel.text = [@"Bank: " stringByAppendingString:[NSString stringWithFormat:@"%.2f", (self.bankAmount - self.betAmountInt)]];
        
        //set the new bank value
        [PFUser.currentUser setValue:[NSNumber numberWithDouble:(self.bankAmount - self.betAmountInt)] forKey:@"bank"];
        
        int betsMade = ([[PFUser.currentUser objectForKey:@"betsMade"] intValue]) + 1;
        [PFUser.currentUser setValue:[NSNumber numberWithInt:betsMade] forKey:@"betsMade"];
        
        //create an animation
        LOTAnimationView *animation = [LOTAnimationView animationNamed:@"success"];
        [self.view addSubview:animation];
        [animation setFrame:self.animationView.frame];
        [animation playWithCompletion:^(BOOL animationFinished) {
            //make a new Bet
            Bet *bet = [[Bet alloc] init];
            bet.payout = self.payoutInt;
            
            NSString *teamSelected = [[NSString alloc] init];
            if ([self team1Selected]) {
                teamSelected = self.team1Label.text;
            } else {
                teamSelected = self.team2Label.text;
            }
            //post the Bet
            [Bet postBetWithEvent:self.event withBetAmount:self.betAmountInt withBetPick:teamSelected withCompletion:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
       
    }
}


//sets the labels to their respective text
-(void) configure   {
    self.team1Label.text = self.event.team1;
    self.team2Label.text = self.event.team2;
    NSString *odds1 = [NSString stringWithFormat:@"%d", self.event.team1Odds];
    NSString *odds2 = [NSString stringWithFormat:@"%d", self.event.team2Odds];
    [self.team1Button setImage:self.event.team1Image.image forState:UIControlStateNormal];    [self.team2Button setImage:self.event.team2Image.image forState:UIControlStateNormal];
    
    
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
    
    self.gameDay = self.event.gameDate;
}


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
    
    self.betAmountInt = [self.betTextField.text doubleValue];
    self.betAmountLabel.text = [NSString stringWithFormat:@"%.2f", self.betAmountInt];
    
    if ([self team1Selected])   {
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
