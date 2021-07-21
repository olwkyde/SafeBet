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
    
    NSString *odds1 = [NSString stringWithFormat:@"%d", event.team1Odds];
    NSString *odds2 = [NSString stringWithFormat:@"%d", event.team2Odds];
    
    //adding plus sign to positive odds
    if (([odds1 characterAtIndex:0] == 45)) {
        cell.team1OddsLabel.text = odds1;
    }   else{
        cell.team1OddsLabel.text = [@"+" stringByAppendingString:odds1];
    }
    if (([odds2 characterAtIndex:0] == 45)) {
        cell.team2OddsLabel.text = odds2;
    }   else{
        cell.team2OddsLabel.text = [@"+" stringByAppendingString:odds2];
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
