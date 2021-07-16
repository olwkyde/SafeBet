//
//  UFCCell.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/15/21.
//

#import "UFCCell.h"
#import "EventCell.h"
#import "Events.h"
#import "UFCEventCell.h"
#import "APIManager.h"
#import "UFCEventCell.h"

@implementation UFCCell


- (UINib *)nib{
    return [UINib nibWithNibName:@"UFCCell" bundle:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    [self.tableView registerNib: [self nib]
//         forCellReuseIdentifier:@"EventCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:EventCell.class forCellReuseIdentifier:@"EventCell"];
    self.tableView.translatesAutoresizingMaskIntoConstraints = false;
    self.tableView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.tableView];
    
    [self fetchBets];
}

- (void) fetchBets  {
    APIManager *api = [APIManager shared];
    [api fetchEventsWithCompletion:^(NSArray *bets, NSError *error)  {
        if (error)  {
            NSLog(@"Error fetching bets: %@", [error localizedDescription]);
        }   else    {
            self.arrayOfBets = bets;
            [self.tableView reloadData];
        }
    }];
}

- (void) setConstraints{
//    [self.tableView.topAnchor constraintEqualToAnchor:self.horizontalSeparator.bottomAnchor constant:15].active = YES;
//    [self.tableView.leadingAnchor constraintEqualToAnchor:self.horizontalSeparator.leadingAnchor].active = YES;
//    [self.tableView.trailingAnchor constraintEqualToAnchor:self.horizontalSeparator.trailingAnchor].active = YES;
//    [self.tableView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:15].active = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EventCell";
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) {
            cell = [[UFCEventCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    
    Events *event = self.arrayOfBets[indexPath.row];
    
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
    return self.arrayOfBets.count;
}


@end
