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
#import "ParseManager.h"

@interface HomeFeedViewController () <UITableViewDelegate, UITableViewDataSource, MakePickControllerDelegate>
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
//    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
    [self fetchUserBets];
    self.data = [NSMutableArray arrayWithCapacity:2];
    [self setUpViews];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    
    self.allEvents = [[NSMutableArray alloc] init];
    self.leagueNames = [[NSMutableArray alloc] init];
    self.leagueNames = [NSMutableArray arrayWithObjects:@"MLB", @"UFC", nil];
    
    [self fetchMLBEvents];
    [self fetchUFCEvents];
}

//code to be run every 10 seconds
- (void)onTimer {
    [self fetchUserBets];
}

//setting up intial settings for title view
- (void)setUpViews  {
    UIImage *titleImage = [UIImage imageNamed:@"logoResized"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    self.navigationItem.titleView = titleImageView;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

//call to fetch UFC Events from the Sports odds API
- (void) fetchUFCEvents  {
    APIManager *api = [APIManager shared];
    [api fetchUFCEventsWithCompletion:^(NSArray *events, NSError *error) { 
        if (error)  {
            NSLog(@"Error fetching bets: %@", [error localizedDescription]);
        }   else    {
            self.ufcEventsArray = events;
            [self.allEvents addObjectsFromArray:self.ufcEventsArray];
            self.leagueNames = [NSMutableArray arrayWithObjects:@"MLB", @"UFC", nil];
            [self.data addObject:events];
            [self.tableView reloadData];
        }
    }];
    [self.refreshControl endRefreshing];
}

//call to fetch MLB events from the Sports odds API
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

//fetches user Bets from the Parse Database to cross-reference with the events displayed on the TableView
- (void) fetchUserBets  {
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

//checks whether a bet the user has placed with the same Event exists
-(Bet *)betExitsForEvent:(nonnull Events*)event  {
    for (Bet *bet in self.userBets) {
        if ([bet.team1 isEqualToString:event.team1] && [bet.team2 isEqualToString:event.team2] && [bet.gameDate isEqualToDate:event.gameDate])  {
            return bet;
        }
    }   return nil;
}

//performs logout function when the logout button is pressed
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
    if([[segue identifier] isEqualToString:@"MakeNewPickSegue"]){
        EventCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Events *event = self.data[indexPath.section][indexPath.row];
        
        MakePickViewController *makePickViewController = [segue destinationViewController];
        makePickViewController.event = event;
        makePickViewController.warningLabel.alpha = 0;
    }   else{
        BetCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Events *event = self.data[indexPath.section][indexPath.row];
        Bet *bet = [self betExitsForEvent:event];
        
        MakePickViewController *makePickViewController = [segue destinationViewController];
        makePickViewController.event = event;
        makePickViewController.bet = bet;
        
        //setting up new controller with new title and team picked highlighted
        makePickViewController.navigationItem.title = @"Make New Pick";
        makePickViewController.betTextField.text = [NSString stringWithFormat:@"%.2f", bet.betAmount];
        if ([bet.betPick isEqualToString:bet.team1])    {
            makePickViewController.team1Label.textColor = [UIColor greenColor];
        }   else{
            makePickViewController.team2Label.textColor = [UIColor greenColor];
        }
        
    }
}

//configures odds so that underdogs get the '+' symbol in front of the odds (an underdog can have +100 odds)
- (NSString *) configureOdds: (nonnull int *) odd{
    NSString *oddString = [NSString stringWithFormat:@"%d", odd];
    if ((([oddString characterAtIndex:0] == 45) || ([oddString characterAtIndex:0] == 43 && [oddString intValue] != 0)) || [oddString isEqualToString:@"100"]) {
        return oddString;
    }   else{
        return [@"+" stringByAppendingString:oddString];
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    EventCell *eventCell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    BetCell *betCell = [tableView dequeueReusableCellWithIdentifier:@"BetCell"];
    
    eventCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    betCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    Events *event = self.data[indexPath.section][indexPath.row];
    Bet *bet = [[Bet alloc] init];
    
    //checking if bet exists for the event
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
        betCell.team1OddsLabel.text = [self configureOdds:bet.team1Odds];
        betCell.team2OddsLabel.text = [self configureOdds:bet.team2Odds];

        if ([bet.betPick isEqualToString:bet.team1])    {
            [betCell.teamPickedImageView setImageWithURL:team1ImageURL];
        }   else {
            [betCell.teamPickedImageView setImageWithURL:team2ImageURL];
        }
        
        return betCell;
    }   else{
        eventCell.team1ImageView.image = event.team1Image.image;
        eventCell.team2ImageView.image = event.team2Image.image;
        eventCell.team1OddsLabel.text = [self configureOdds:event.team1Odds];
        eventCell.team2OddsLabel.text = [self configureOdds:event.team2Odds];
        eventCell.event = event;
        eventCell.dayLabel.text = event.date;
        eventCell.timeLabel.text = event.time;
        eventCell.team1Label.text = event.team1;
        eventCell.team2Label.text = event.team2;
       
        return eventCell;
    }

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

- (void)madeBet:(Bet * _Nonnull) bet    {
    [self fetchUserBets];
}

@end
