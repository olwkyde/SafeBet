//
//  ParseManager.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/30/21.
//

#import "ParseManager.h"
#import <Parse/Parse.h>
#import "Bet.h"

@implementation ParseManager

+ (instancetype)shared {
    static ParseManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

//fetches all the bets the user has made
-(void)fetchUserBetsWithCompletion:(void (^)(NSArray *betsPlaced, NSError *error))completion   {
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
            completion(bets, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}


-(void) fetchBet:(Bet * _Nonnull)bet withCompletion:(void (^)(PFObject *userBet, NSError *error))completion   {
    // construct query for the bet
    PFQuery *query = [PFQuery queryWithClassName:@"Bet"];
    [query includeKey:@"author"];
    [query includeKeys:[NSArray arrayWithObjects:@"author", @"gameDate", @"team2Image", @"team1Image", @"betPick", @"team1", @"team2", @"team1Odds", nil]];
    [query includeKey:@"createdAt"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"gameDate" equalTo:bet.gameDate];
    [query whereKey:@"team1" equalTo:bet.team1];
    [query whereKey:@"team2" equalTo:bet.team2];
    [query orderByDescending:@"createdAt"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            completion(object, nil);
        }   else{
            completion(nil, error);
        }}];
}






@end
