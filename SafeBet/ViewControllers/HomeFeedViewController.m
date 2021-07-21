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

@interface HomeFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logOutButton;
@property (strong, nonatomic) NSMutableArray *arrayOfBets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *mlbEventArray;
@property (strong, nonatomic) NSMutableArray *allEvents;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *leagueNames;


@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    self.data = [[NSMutableArray alloc] init];
    self.allEvents = [[NSMutableArray alloc] init];
    self.leagueNames = [[NSMutableArray alloc] init];
    self.leagueNames = [NSMutableArray arrayWithObjects:@"MLB", @"UFC", nil];
    [self fetchMLBEvents];
    [self fetchBets];
    
    
    
    
}

- (void) fetchBets  {
    APIManager *api = [APIManager shared];
    
    [api fetchEventsWithCompletion:^(NSArray *bets, NSError *error)  {
        if (error)  {
            NSLog(@"Error fetching bets: %@", [error localizedDescription]);
        }   else    {
            self.arrayOfBets = bets;
            [self.allEvents addObjectsFromArray:self.arrayOfBets];
            [self.data addObject:bets];
            [self.tableView reloadData];
        }
    }];
}

- (void) fetchMLBEvents {
    APIManager *api = [APIManager shared];
    
    [api fetchMLBEventsWithCompletion:^(NSArray *bets, NSError *error)  {
        if (error)  {
            NSLog(@"Error fetching bets: %@", [error localizedDescription]);
        }   else    {
            self.mlbEventArray = bets;
            [self.allEvents addObjectsFromArray:self.mlbEventArray];
            [self.data addObject:bets];
            [self.tableView reloadData];
        }
    }];
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
    
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    Events *event = self.data[indexPath.section][indexPath.row];
    
    cell.event = event;
    cell.dayLabel.text = event.date;
    cell.timeLabel.text = event.time;
    cell.team1Label.text = event.team1;
    cell.team2Label.text = event.team2;
    
    //add the plus sign if the odds are positive
    if (event.team1Odds <= 100) {
        cell.team1OddsLabel.text = [NSString stringWithFormat:@"%d", event.team1Odds];

    }   else{
        cell.team1OddsLabel.text = [@"+" stringByAppendingString:[NSString stringWithFormat:@"%d", event.team1Odds]];
    }
    if (event.team2Odds <= 100) {
        cell.team2OddsLabel.text = [NSString stringWithFormat:@"%d", event.team2Odds];

    }   else{
        cell.team2OddsLabel.text = [@"+" stringByAppendingString:[NSString stringWithFormat:@"%d", event.team2Odds]];
    }
    
    //take out the + sign in front of the odds if it has been erroneously placed in front of a - odd
    if (([cell.team1OddsLabel.text characterAtIndex:0] == '+') && ([cell.team1OddsLabel.text characterAtIndex:1] == '-'))   {
        cell.team1OddsLabel.text = [cell.team1OddsLabel.text substringFromIndex:1];
    }
    
    if (([cell.team2OddsLabel.text characterAtIndex:0] == '+') && ([cell.team2OddsLabel.text characterAtIndex:1] == '-'))   {
        cell.team2OddsLabel.text = [cell.team2OddsLabel.text substringFromIndex:1];
    }
    
    return cell;
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
