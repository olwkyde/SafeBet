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
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showIndicatorView];
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

- (void)viewDidAppear:(BOOL)animated    {
    [self fetchUserBets];
    [self.tableView reloadData];
}

//setting up intial settings for title view
- (void)setUpViews  {
    UIImage *titleImage = [UIImage imageNamed:@"logoResized"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    self.navigationItem.titleView = titleImageView;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

-(void)showIndicatorView    {
    self.activityIndicator.hidesWhenStopped = true;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 50, (self.view.frame.size.width / 2) - 50, 100, 100)];
    container.backgroundColor = [UIColor clearColor];
    
    [container addSubview:self.activityIndicator];
    [self.view insertSubview:container atIndex:0];
    [self.activityIndicator startAnimating];
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
    [self.activityIndicator stopAnimating];
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
        makePickViewController.delegate = self;
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
    if ((([oddString characterAtIndex:0] == 45) || ([oddString characterAtIndex:0] == 43))) {
        return oddString;
    }   else if ([oddString isEqualToString:@"100"])    {
        return @"+100";
    }
    else{
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
        betCell.betAmountLabel.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%.2f", bet.betAmount]];

        betCell.dayLabel.text = event.date;
        betCell.timeLabel.text = event.time;
        
        if ([bet.sport isEqualToString:@"MLB"] ) {
            betCell.team1ImageView.image = [UIImage imageNamed:bet.team1];
            betCell.team2ImageView.image = [UIImage imageNamed:bet.team2];
        }   else    {
            betCell.team1ImageView.image = event.team1Image.image;
            betCell.team2ImageView.image = event.team2Image.image;
        }


        betCell.team1Label.text = bet.team1;
        betCell.team2Label.text = bet.team2;
        NSString *team1OddsString = [self configureOdds:event.team1Odds];
        NSString *team2OddsString = [self configureOdds:event.team2Odds];
        betCell.team1OddsLabel.text = team1OddsString;
        betCell.team2OddsLabel.text = team2OddsString;

        if ([bet.betPick isEqualToString:bet.team1])    {
            betCell.teamPickedImageView.image = betCell.team1ImageView.image;
        }   else {
            betCell.teamPickedImageView.image = betCell.team2ImageView.image;
        }
        
        return betCell;
    }   else{
        eventCell.team1ImageView.image = event.team1Image.image;
        eventCell.team2ImageView.image = event.team2Image.image;
        eventCell.team1OddsLabel.text = [NSString stringWithFormat:@"%+d", event.team1Odds];
        eventCell.team2OddsLabel.text = [NSString stringWithFormat:@"%+d", event.team2Odds];
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
    [self.tableView reloadData];
}

@end
