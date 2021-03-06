//
//  ProfileViewController.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/24/21.
//

#import "ProfileViewController.h"
#import "Events.h"
#import <Parse/Parse.h>
#import "Bet.h"
#import "BetCell.h"
#import "NSDate+DateTools.h"
#import "UIImageView+AFNetworking.h"
#import "MakePickViewController.h"
#import "HTMLManager.h"
#import "ParseManager.h"
#import "SCLAlertView.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MakePickControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *userBets;
@property (nonatomic, strong) UIRefreshControl *viewRefreshControl;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *profileTapGestureRecognizer;
@property (strong, nonatomic) UIAlertController *alert;

@end

@implementation ProfileViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setUpViews];
    [self fetchBets];
    UITapGestureRecognizer *profileImageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTapped)];
    [self.profileImageView addGestureRecognizer:profileImageTapGesture];
    [self.profileImageView setUserInteractionEnabled:true];
}

- (void)viewDidAppear:(BOOL)animated    {
    [self setUpViews];
    [self fetchBets];
}


-(void) setUpViews  {
    self.usernameLabel.text = [PFUser currentUser].username;
    self.profileImageView.layer.cornerRadius = (self.profileImageView.frame.size.width / 2);
    
    self.tableView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    double bankAmount = [[PFUser.currentUser objectForKey:@"bank"] doubleValue];
    self.bankLabel.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%.2f", bankAmount]];
    int betsMade = [[PFUser.currentUser objectForKey:@"betsMade"] intValue];
    self.betsMadeLabel.text = [NSString stringWithFormat:@"%d", betsMade];
    int betsWon = [[PFUser.currentUser objectForKey:@"betsWon"] intValue];
    self.betsWonLabel.text = [NSString stringWithFormat:@"%d", betsWon];
    
    PFFileObject *profileImage = [PFUser.currentUser objectForKey:@"profilePicture"];
    NSURL *profileImageURL = [NSURL URLWithString:profileImage.url];
    
    [self.profileImageView setImageWithURL:profileImageURL];
    [self.viewRefreshControl endRefreshing];
}

- (void) fetchBets  {
    // construct query
    ParseManager *parseManager = [ParseManager shared];
    [parseManager fetchUserBetsWithCompletion:^(NSArray * _Nonnull betsPlaced, NSError * _Nonnull error) {
        if (betsPlaced) {
            self.userBets = betsPlaced;
            [self.tableView reloadData];
        }   else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}


#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"EditPickSegue"])    {
        BetCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Bet *bet = self.userBets[indexPath.row];
        
        MakePickViewController *makePickViewController = [segue destinationViewController];
        makePickViewController.delegate = self;
        makePickViewController.bet = bet;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    BetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BetCell"];
    
    //initialize bet and set it to each array index
    Bet *bet = [[Bet alloc] init];
    bet = self.userBets[indexPath.row];
        
    //check MLB events for whether they've been won 12 hours after they have occured, UFC events for 72 hours after
    NSDate *now = [NSDate date];
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:bet.gameDate];
    int numberOfHours = secondsBetween / 3600;
        
    //check for MLB results that haven't been checked yet
    if (numberOfHours >= 24  && bet.payout == -1.0 && [bet.sport isEqualToString:@"MLB"])    {
        HTMLManager *htmlManager = [HTMLManager shared];
        bool didWinBet = [htmlManager didWinMLBBet:bet];
        if (didWinBet)  {
            [bet wonBet];
        }   else{
            [bet lostBet];
        }
        [self setUpViews];
    }
    
    //check for UFC fight results that haven't been checked yet
    if (numberOfHours >= 72 && bet.payout == -1.0 && [bet.sport isEqualToString:@"UFC"])    {
        HTMLManager *htmlManager = [HTMLManager shared];
        bool didWinBet = [htmlManager didWinUFCBetWithBet:bet];
        if (didWinBet)  {
            [bet wonBet];
        }   else{
            [bet lostBet];
        }
        [self setUpViews];
    }
    
    //display the payout based on whether the user won the bet
    if (bet.payout > 0.0)   {
        cell.payoutAmountLabel.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%.2f", bet.payout]];
        cell.payoutAmountLabel.textColor = [UIColor greenColor];
    }
    else if (bet.payout == 0)   {
        cell.payoutAmountLabel.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%.2f", bet.payout]];
        cell.payoutAmountLabel.textColor = [UIColor redColor];
    }   else    {
        cell.payoutAmountLabel.text = @"";
    }
    
    cell.betAmountLabel.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%.2f", bet.betAmount]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDate *gameDate = bet.gameDate;
    
    int gameHour = (int) gameDate.hour;
    int gameMinute = (int) gameDate.minute;
    
    NSString *am = @" AM";
    NSString *pm = @" PM";
    if (gameHour > 12) {
        gameHour = gameHour - 12;
        cell.timeLabel.text = [NSString stringWithFormat:@"%d%@%02d%@", gameHour, @":", gameMinute, pm];
    }   else if (gameHour == 12)    {
        cell.timeLabel.text = [NSString stringWithFormat:@"%d%@%02d%@", gameHour, @":", gameMinute, pm];
    }   else if (gameHour == 0) {
        cell.timeLabel.text = [NSString stringWithFormat:@"%d%@%02d%@", 12, @":", gameMinute, am];
    }   else{
        cell.timeLabel.text = [NSString stringWithFormat:@"%d%@%d%@", gameHour, @":", gameMinute, am];
    }
    
    int gameDay = (int) gameDate.day;
    int gameMonth = (int) gameDate.month;
    int gameYear = (gameDate.year % 100);
    
    cell.dayLabel.text = [NSString stringWithFormat:@"%d%@%d%@%d", gameMonth, @"/", gameDay, @"/", gameYear];
    
    cell.team1Label.text = bet.team1;
    cell.team1OddsLabel.text = [self configureOdds:bet.team1Odds];
    
    cell.team2Label.text = bet.team2;
    cell.team2OddsLabel.text = [self configureOdds:bet.team2Odds];
    
    if ([bet.sport isEqualToString:@"MLB"]) {
        cell.team1ImageView.image = [UIImage imageNamed:bet.team1];
        cell.team2ImageView.image = [UIImage imageNamed:bet.team2];
        if ([bet.betPick isEqualToString:bet.team1])    {
            cell.teamPickedImageView.image = cell.team1ImageView.image;
        }   else    {
            cell.teamPickedImageView.image = cell.team2ImageView.image;
        }
    }   else    {
        PFFileObject *team1Image = bet.team1image;
        NSURL *team1ImageURL = [NSURL URLWithString:team1Image.url];
        [cell.team1ImageView setImageWithURL:team1ImageURL];

        
        PFFileObject *team2Image = bet.team2image;
        NSURL *team2ImageURL = [NSURL URLWithString:team2Image.url];
        [cell.team2ImageView setImageWithURL:team2ImageURL];
        
        if ([bet.betPick isEqualToString:bet.team1])  {
            [cell.teamPickedImageView setImageWithURL:team1ImageURL];
        }   else{
            [cell.teamPickedImageView setImageWithURL:team2ImageURL];
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userBets.count;
}

- (NSString *) configureOdds: (nonnull int *) odd{
    NSString *oddString = [NSString stringWithFormat:@"%d", odd];
    if ((([oddString characterAtIndex:0] == 45) || ([oddString characterAtIndex:0] == 43))) {
        return oddString;
    }   else if ([oddString isEqualToString:@"100"])    {
        return @"+100";
    }
    else{
        return [@"+" stringByAppendingString:oddString];
    }
}

//presents the image picker controller when the image is tapped
-(void) profileImageTapped   {
    //instantiate a UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    //checks whether there is a valid camera to use; if not, the photo library is used instead
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }   else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    //presents the UIImagePickerController
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Resize the image
    UIImage *finalImage = [self resizeImage:editedImage withSize: CGSizeMake(self.profileImageView.frame.size.width, self.profileImageView.frame.size.height)];
    
    self.profileImageView.image = finalImage;
    
    //set user's profile picture in Parse to picture chosen
    PFUser *user = [PFUser currentUser];
    NSData *imageData = UIImagePNGRepresentation(finalImage);
    PFObject *imageToUpload = [PFFileObject fileObjectWithName:@"profilePicture.png" data:imageData];
    user[@"profilePicture"] = imageToUpload;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)  {
            [self dismissViewControllerAnimated:YES completion:nil];
        }   else{
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *now = [NSDate date];
    Bet *bet = [[Bet alloc] init];
    bet = self.userBets[indexPath.row];
    
    if (bet.payout == -1.0) {
        if ([now compare:bet.gameDate] == NSOrderedAscending)  {
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            
            MakePickViewController * makePickViewController = [storyboard instantiateViewControllerWithIdentifier:@"MakePickViewController"];
            
            //configure event out of bet
            Events *event = [self eventOfBet:bet];
            //set the bet and event to the MakePick Conreoller's bet and event
            makePickViewController.bet = bet;
            makePickViewController.event = event;
            
            [self presentViewController:makePickViewController animated:YES completion:nil];
        }   else    {
            self.alert = [UIAlertController alertControllerWithTitle:@"Error"  message:@"This event already underway or has already ended." preferredStyle:(UIAlertControllerStyleAlert)];
            // create a CANCEL action
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            //add an ok action to the alert andn present it
            [self.alert addAction:okAction];
            [self presentViewController:self.alert animated:YES completion:^{
            }];
        }
    }
}

-(Events *)eventOfBet: (Bet *) bet  {
    Events *event = [[Events alloc] init];
    event.team1 = bet.team1;
    event.team2 = bet.team2;
    event.team1Odds = bet.team1Odds;
    event.team2Odds = bet.team2Odds;
    event.sport = bet.sport;
    
    //fetch picture data and set it to the event image
    if ([bet.sport isEqualToString:@"MLB"]) {
        event.team1Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:event.team1]];
        event.team2Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:event.team2]];
    }   else{
        PFFileObject *team1Image = bet.team1image;
        NSData *team1ImageData = [team1Image getData];
        UIImage *team1Picture = [UIImage imageWithData:team1ImageData];
        event.team1Image = [[UIImageView alloc] initWithImage:team1Picture];

        PFFileObject *team2Image = bet.team2image;
        NSData *team2ImageData = [team2Image getData];
        UIImage *team2Picture = [UIImage imageWithData:team2ImageData];
        event.team2Image = [[UIImageView alloc] initWithImage:team2Picture];
    }
    event.gameDate = bet.gameDate;
    
    return event;
}

//protocol to fetch user bets once one has been submitted
- (void)madeBet:(Bet * _Nonnull)bet {
    [self setUpViews];
    [self fetchBets];
    [self.tableView reloadData];
}

- (IBAction)moneyRequestPressed:(id)sender {
    SCLAlertViewBuilder *builder = [SCLAlertViewBuilder new]
    .addButtonWithActionBlock(@"Add Money", ^{
        
        NSDate *now = [NSDate date];
        
        //grab the bank amount and how many outstanding bets have been made
        double bank = [[PFUser.currentUser objectForKey:@"bank"] doubleValue];
        __block int outstandingBetCount;
        NSDate *lastBanked = [PFUser.currentUser objectForKey:@"lastBanked"];
        __block NSArray *oustandingBets;
        __block bool doesBigBetExist;
        
        NSTimeInterval secondsBetween = [lastBanked timeIntervalSinceDate:now];
        
        //check how many outstanding bets there are
        ParseManager *parseManager = [ParseManager shared];
        [parseManager fetchOutstandingBetsWithCompletion:^(NSArray * _Nonnull betsPlaced, NSError * _Nonnull error) {
            if (betsPlaced) {
                oustandingBets = betsPlaced;
                outstandingBetCount = (int) betsPlaced.count;
                doesBigBetExist = [self doesBigBetExistWithArray:oustandingBets];
                
                //present an error alertview if either the bank is greater than 25, the outstanding bet count is greater than 3, or it has been less than a week since the last time the user placed a bet
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                if (bank >= 25.0 || outstandingBetCount >= 3)   {
                    //make an alert
                    [alert showWarning:self title:@"Error" subTitle:@"You cannot add funds if your bank has over $25 or you have more than 3 outstanding bets." closeButtonTitle:@"Done" duration:0.0f];
                }
                   else if (doesBigBetExist)   {
                    [alert showWarning:self title:@"Error" subTitle:@"One of your outstanding bets are too big. Lower the price of your bet." closeButtonTitle:@"Done" duration:0.0f];
                }
                    else if ((secondsBetween <= 604800 & secondsBetween != 0))  {
                    //get the amount of days and hours until the next possible pump of cash
                    int daysRemaining = (604800 - secondsBetween) / 86400;
                    int hoursRemaining = ((604800 - secondsBetween) - (86400 * daysRemaining)) / 3600;
                        
                    NSString *subtitle = [NSString stringWithFormat:@"You cannot add funds if you've had a pump within the last week. You have %d days and %d hours before the next earliest pump.", daysRemaining, hoursRemaining];
                    [alert showWarning:self title:@"Error" subTitle:subtitle closeButtonTitle:@"Done" duration:0.0f];
                }
                    else    {
                    PFUser *user = [PFUser currentUser];
                    double userBank = [user[@"bank"] doubleValue];
                    user[@"bank"] = [NSNumber numberWithDouble:(userBank + 100.)];
                    user[@"lastBanked"] = [NSDate now];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error != nil)  {
                            NSLog(@"%@", [error localizedDescription]);
                            [self setUpViews];
                        }
                    }];
                }
            }
        }];
    });
    SCLAlertViewShowBuilder *showBuilder = [SCLAlertViewShowBuilder new]
    .style(SCLAlertViewStyleInfo)
    .title(@"Add money here")
    .subTitle(@"You can add $100 to your bank")
    .duration(0);
    [showBuilder showAlertView:builder.alertView onViewController:self];
    // or even
    showBuilder.show(builder.alertView, self);
    [self setUpViews];
}

//checks if there is a big bet that the user has made. a big bet is defined as a bet that is more than half the bank. this is to prevent useres from making big bets, adding a pump of money, then easing up on the bet amount to garner even more money 
-(bool) doesBigBetExistWithArray:(NSArray * _Nonnull)betsPlaced {
    double bank = [[PFUser.currentUser objectForKey:@"bank"] doubleValue];
    for (Bet *bet in betsPlaced)    {
        NSLog(@"%.2f", bet.betAmount);
        if (bet.betAmount >= bank)  {
            return true;
        }
    } return false;
}

@end
