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

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
    [self.profileImageView setUserInteractionEnabled:true];
}

- (void)onTimer {
    [self setUpViews];
    [self fetchBets];
}


-(void) setUpViews  {
    self.usernameLabel.text = [PFUser currentUser].username;
    self.profileImageView.layer.cornerRadius = (self.profileImageView.frame.size.width / 2);
    
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
    PFQuery *query = [PFQuery queryWithClassName:@"Bet"];
    [query includeKey:@"author"];
    [query includeKeys:[NSArray arrayWithObjects:@"author", @"gameDate", @"team2Image", @"team1Image", @"betPick", @"team1", @"team2", @"team1Odds", nil]];
    [query includeKey:@"createdAt"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *bets, NSError *error) {
        if (bets != nil) {
            self.userBets = bets;
            [self.tableView reloadData];
        } else {
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
        makePickViewController.bet = bet;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    BetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BetCell"];
    
    //initialize bet and set it to each array index
    Bet *bet = [[Bet alloc] init];
    bet = self.userBets[indexPath.row];
    
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
    }   else{
        cell.timeLabel.text = [NSString stringWithFormat:@"%d%@%d%@", gameHour, @":", gameMinute, am];
    }
    
    int gameDay = (int) gameDate.day;
    int gameMonth = (int) gameDate.month;
    int gameYear = (gameDate.year % 100);
    
    cell.dayLabel.text = [NSString stringWithFormat:@"%d%@%d%@%d", gameMonth, @"/", gameDay, @"/", gameYear];
    
    cell.team1Label.text = bet.team1;
    cell.team1OddsLabel.text = [NSString stringWithFormat:@"%d", bet.team1Odds];
    
    PFFileObject *team1Image = bet.team1image;
    NSURL *team1ImageURL = [NSURL URLWithString:team1Image.url];
    [cell.team1ImageView setImageWithURL:team1ImageURL];
    
    PFFileObject *team2Image = bet.team2image;
    NSURL *team2ImageURL = [NSURL URLWithString:team2Image.url];
    [cell.team2ImageView setImageWithURL:team2ImageURL];
    
    cell.team2Label.text = bet.team2;
    cell.team2OddsLabel.text = [NSString stringWithFormat:@"%d", bet.team2Odds];

    
    if ([bet.betPick isEqualToString:bet.team1])    {
        [cell.teamPickedImageView setImageWithURL:team1ImageURL];
    }   else    {
        [cell.teamPickedImageView setImageWithURL:team2ImageURL];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userBets.count;
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

-(Events *)eventOfBet: (Bet *) bet  {
    Events *event = [[Events alloc] init];
    event.team1 = bet.team1;
    event.team2 = bet.team2;
    event.team1Odds = bet.team1Odds;
    event.team2Odds = bet.team2Odds;
    
    //fetch picture data and set it to the event image
    PFFileObject *team1Image = bet.team1image;
    NSData *team1ImageData = [team1Image getData];
    UIImage *team1Picture = [UIImage imageWithData:team1ImageData];
    event.team1Image = [[UIImageView alloc] initWithImage:team1Picture];
    
    PFFileObject *team2Image = bet.team2image;
    NSData *team2ImageData = [team2Image getData];
    UIImage *team2Picture = [UIImage imageWithData:team2ImageData];
    event.team2Image = [[UIImageView alloc] initWithImage:team2Picture];
    
    return event;
}

@end
