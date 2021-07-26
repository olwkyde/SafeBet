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

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *userBets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setUpViews];
    [self fetchBets];
}

-(void) setUpViews  {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchBets) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.usernameLabel.text = [PFUser currentUser].username;
    self.profileImageView.layer.cornerRadius = (self.profileImageView.frame.size.width / 2);
    self.profileImageButton.layer.cornerRadius = (self.profileImageButton.frame.size.width / 2);
    
    double bankAmount = [[PFUser.currentUser objectForKey:@"bank"] doubleValue];
    self.bankLabel.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%.2f", bankAmount]];
    int betsMade = [[PFUser.currentUser objectForKey:@"betsMade"] intValue];
    self.betsMadeLabel.text = [NSString stringWithFormat:@"%d", betsMade];
    int betsWon = [[PFUser.currentUser objectForKey:@"betsWon"] intValue];
    self.betsWonLabel.text = [NSString stringWithFormat:@"%d", betsWon];
    
    PFFileObject *profileImage = [PFUser.currentUser objectForKey:@"profilePicture"];
    NSURL *profileImageURL = [NSURL URLWithString:profileImage.url];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: profileImageURL];
    
//    [self.profileImageView setImageWithURL:profileImageURL];
    [self.profileImageButton.imageView setImageWithURL:profileImageURL];
    [self.profileImageButton setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
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
    [self.refreshControl endRefreshing];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)profileImageButtonPressed:(id)sender {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Resize the image
    UIImage *finalImage = [self resizeImage:editedImage withSize: CGSizeMake(self.profileImageButton.frame.size.width, self.profileImageButton.frame.size.height)];
    
    //set profileImage to new image
//    self.profileImageView.image = finalImage;
    self.profileImageButton.imageView.image = finalImage;
    [self.profileImageButton setImage:finalImage forState:UIControlStateNormal];
    
    //set user's profile picture in Parse to picture chosen
    PFFileObject *finalImageFile = [PFFileObject fileObjectWithName:@"profileImage.png" data:UIImagePNGRepresentation(finalImage)];
    
    [PFUser.currentUser setValue:finalImageFile forKey:@"profilePicture"];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
