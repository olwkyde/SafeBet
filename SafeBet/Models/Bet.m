//
//  Bet.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import "Bet.h"
#import <Parse/Parse.h>
#import "ProfileViewController.h"


@implementation Bet

+ (nonnull NSString *)parseClassName {
    return @"Bet";
}

+(void) postBetWithEvent: ( Events * _Nonnull )event withBetAmount: (double)betAmount withBetPick: (NSString * _Nonnull)betPick withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Bet *newBet = [Bet new];
    newBet.author = [PFUser currentUser];

    newBet.betAmount = betAmount;
    newBet.sport = event.sport;
    newBet.betPick = betPick;
    newBet.gameDate = event.gameDate;
    newBet.team1 = event.team1;
    newBet.team1Odds = event.team1Odds;
    newBet.team1image = [self getPFFileFromImage:event.team1Image.image];
    newBet.team2 = event.team2;
    newBet.team2Odds = event.team2Odds;
    newBet.team2image = [self getPFFileFromImage:event.team2Image.image];
    newBet.payout = -1.0;
    newBet.payoutPossible = [newBet getPayoutAmountWithBet];
    [newBet saveInBackgroundWithBlock:completion];
}

- (double) getPayoutAmountWithBet{
    int pickOdds;
    double payout;
    //setting the pickOdds based off of the bet pick
    if ([self.betPick isEqualToString:self.team1])  {
        pickOdds = self.team1Odds;
    }   else{
        pickOdds = self.team2Odds;
    }
    
    if (pickOdds >= 0)  {
        payout = ((pickOdds + 100.) * self.betAmount) / 100;
    }   else{
        payout = ((100) * self.betAmount / pickOdds) + self.betAmount;
    }
    return payout;
}

//deletes a bet
- (void) deleteBet  {
    // construct query for the old bet
    PFQuery *query = [PFQuery queryWithClassName:@"Bet"];
    [query includeKey:@"author"];
    [query includeKeys:[NSArray arrayWithObjects:@"author", @"gameDate", @"team2Image", @"team1Image", @"betPick", @"team1", @"team2", @"team1Odds", nil]];
    [query includeKey:@"createdAt"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"gameDate" equalTo:self.gameDate];
    [query whereKey:@"team1" equalTo:self.team1];
    [query whereKey:@"team2" equalTo:self.team2];
    [query orderByDescending:@"createdAt"];

    // delete row asynchronously, deletes a bet from bet made
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            //give the money back for the old bet
            int betsMade = [[PFUser.currentUser objectForKey:@"betsMade"] intValue];
            [PFUser.currentUser setValue: [NSNumber numberWithInt:(betsMade - 1)] forKey:@"betsMade"];
            NSLog(@"%d", betsMade);
            [object deleteInBackground];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void) lostBet {
    // construct query for the bet
    PFQuery *query = [PFQuery queryWithClassName:@"Bet"];
    [query includeKey:@"author"];
    [query includeKeys:[NSArray arrayWithObjects:@"author", @"gameDate", @"team2Image", @"team1Image", @"betPick", @"team1", @"team2", @"team1Odds", nil]];
    [query includeKey:@"createdAt"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"gameDate" equalTo:self.gameDate];
    [query whereKey:@"team1" equalTo:self.team1];
    [query whereKey:@"team2" equalTo:self.team2];
    [query orderByDescending:@"createdAt"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            self.didWinBet = false;
            self.payout = 0.0;
        }
    }];
}

-(void) wonBet{
    // construct query for the bet
    PFQuery *query = [PFQuery queryWithClassName:@"Bet"];
    [query includeKey:@"author"];
    [query includeKeys:[NSArray arrayWithObjects:@"author", @"gameDate", @"team2Image", @"team1Image", @"betPick", @"team1", @"team2", @"team1Odds", nil]];
    [query includeKey:@"createdAt"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"gameDate" equalTo:self.gameDate];
    [query whereKey:@"team1" equalTo:self.team1];
    [query whereKey:@"team2" equalTo:self.team2];
    [query orderByDescending:@"createdAt"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            //set payout to the possible payout and set didWin to true
            self.didWinBet = true;
            self.payout = self.payoutPossible;
            
            PFUser *user = [PFUser currentUser];
            int betsWon = [[PFUser.currentUser objectForKey:@"betsWon"] intValue];
            object[@"payout"] = [NSNumber numberWithDouble:self.payout];
            user[@"betsWon"] = [NSNumber numberWithInt:(betsWon + 1)];
            
            double bank = [[PFUser.currentUser objectForKey:@"bank"] intValue];
            user[@"bank"] = [NSNumber numberWithDouble:(bank + self.payout)];
            
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil)  {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil)  {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }];
        }
    }];
}




//creates a PFFileObject out of a UIImage
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}
@end
