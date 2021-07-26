//
//  HomeFeedViewController.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/10/21.
//

#import "HomeFeedViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "EventCell.h"
#import "APIManager.h"
#import "Events.h"
#import "MakePickViewController.h"
#import "Bet.h"
#import "BetCell.h"
#import "UIImageView+AFNetworking.h"

@interface HomeFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logOutButton;
@property (strong, nonatomic) NSMutableArray *ufcEventsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *mlbEventArray;
@property (strong, nonatomic) NSMutableArray *allEvents;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *leagueNames;
@property (strong, nonatomic) NSMutableArray *userBets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;


@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchUserBets];
    self.data = [NSMutableArray arrayWithCapacity:2];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
    
    self.allEvents = [[NSMutableArray alloc] init];
    self.leagueNames = [[NSMutableArray alloc] init];
    self.leagueNames = [NSMutableArray arrayWithObjects:@"MLB", @"UFC", nil];
    
    [self fetchMLBEvents];
    [self fetchUFCEvents];
}

- (void)onTimer {
    [self.tableView reloadData];
}

- (void) fetchUFCEvents  {
    APIManager *api = [APIManager shared];
    
    [api fetchEventsWithCompletion:^(NSArray *bets, NSError *error)  {
        if (error)  {
            NSLog(@"Error fetching bets: %@", [error localizedDescription]);
        }   else    {
            self.ufcEventsArray = bets;
            [self.allEvents addObjectsFromArray:self.ufcEventsArray];
            self.leagueNames = [NSMutableArray arrayWithObjects:@"MLB", @"UFC", nil];
            [self.data addObject:bets];
            [self.tableView reloadData];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void) fetchMLBEvents {
    APIManager *api = [APIManager shared];
    
    [api fetchMLBEventsWithCompletion:^(NSArray *bets, NSError *error)  {
        if (error)  {
            NSLog(@"Error fetching bets: %@", [error localizedDescription]);
        }   else    {
            self.mlbEventArray = bets;
            [self.allEvents addObjectsFromArray:self.mlbEventArray];
            self.leagueNames = [NSMutableArray arrayWithObjects:@"UFC", @"MLB", nil];
            [self.data addObject:bets];
            [self.tableView reloadData];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void) fetchUserBets  {
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

-(Bet *)betExitsForEvent:(nonnull Events*)event  {
    for (Bet *bet in self.userBets) {
        if ([bet.team1 isEqualToString:event.team1] && [bet.team2 isEqualToString:event.team2] && [bet.gameDate isEqualToDate:event.gameDate])  {
            return bet;
        }
    }   return nil;
}



- (IBAction)logOutButton:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        myDelegate.window.rootViewController = loginViewController;
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"MakePickSegue"]){
        EventCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Events *event = self.data[indexPath.section][indexPath.row];
        
        MakePickViewController *makePickViewController = [segue destinationViewController];
        makePickViewController.event = event;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    EventCell *eventCell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    BetCell *betCell = [tableView dequeueReusableCellWithIdentifier:@"BetCell"];
    
    eventCell.layer.cornerRadius = 5;
    betCell.layer.cornerRadius = 5;
    
    Events *event = self.data[indexPath.section][indexPath.row];
    
    //odds in string form (only here because it is used for both the betCell configuration and the eventCell configuration
    NSString *odds1 = [NSString stringWithFormat:@"%d", event.team1Odds];
    NSString *odds2 = [NSString stringWithFormat:@"%d", event.team2Odds];
    
    Bet *bet = [[Bet alloc] init];
    bet = [self betExitsForEvent:event];
    if (bet != nil) {

        betCell.betAmountLabel.text = [NSString stringWithFormat:@"%.2f", bet.betAmount];

        betCell.dayLabel.text = event.date;
        betCell.timeLabel.text = event.time;

        PFFileObject *team1ImageFile = bet.team1image;
        NSURL *team1ImageURL = [NSURL URLWithString:team1ImageFile.url];
        [betCell.team1ImageView setImageWithURL:team1ImageURL];

        PFFileObject *team2ImageFile = bet.team2image;
        NSURL *team2ImageURL = [NSURL URLWithString:team2ImageFile.url];
        [betCell.team2ImageView setImageWithURL:team2ImageURL];

        betCell.team1Label.text = bet.team1;
        betCell.team2Label.text = bet.team2;
        

        //adding plus sign to positive odds
        if (([odds1 characterAtIndex:0] == 45)) {
            betCell.team1OddsLabel.text = odds1;
        }   else{
            betCell.team1OddsLabel.text = [@"+" stringByAppendingString:odds1];
        }
        if (([odds2 characterAtIndex:0] == 45)) {
            betCell.team2OddsLabel.text = odds2;
        }   else{
            betCell.team2OddsLabel.text = [@"" stringByAppendingString:odds2];
        }

        if ([bet.betPick isEqualToString:bet.team1])    {
            [betCell.teamPickedImageView setImageWithURL:team1ImageURL];
        }   else {
            [betCell.teamPickedImageView setImageWithURL:team2ImageURL];
        }

        

        return betCell;
    }
    
    eventCell.team1ImageView.layer.cornerRadius = (eventCell.team1ImageView.frame.size.width / 2);
    eventCell.team2ImageView.layer.cornerRadius = (eventCell.team2ImageView.frame.size.width / 2);
    eventCell.team1ImageView.image = event.team1Image.image;
    eventCell.team2ImageView.image = event.team2Image.image;

    
    eventCell.event = event;
    eventCell.dayLabel.text = event.date;
    eventCell.timeLabel.text = event.time;
    eventCell.team1Label.text = event.team1;
    eventCell.team2Label.text = event.team2;
    
    
    //adding plus sign to positive odds
    if (([odds1 characterAtIndex:0] == 45)) {
        eventCell.team1OddsLabel.text = odds1;
    }   else{
        eventCell.team1OddsLabel.text = [@"+" stringByAppendingString:odds1];
    }
    if (([odds2 characterAtIndex:0] == 45)) {
        eventCell.team2OddsLabel.text = odds2;
    }   else{
        eventCell.team2OddsLabel.text = [@"+" stringByAppendingString:odds2];
    }
    return eventCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray*)self.data[section]).count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    return self.data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.leagueNames[section];
}


@end
