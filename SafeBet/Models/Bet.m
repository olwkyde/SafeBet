//
//  Bet.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import "Bet.h"
#import <Parse/Parse.h>
#import "ProfileViewController.h"
#import "ParseManager.h"


@implementation Bet

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic team1;
@dynamic team2;
@dynamic gameDate;
@dynamic date;
@dynamic team1Odds;
@dynamic team2Odds;
@dynamic team1image;
@dynamic team2image;
@dynamic betAmount;
@dynamic didWinBet;
@dynamic betPick;
@dynamic payout;
@dynamic sport;
@dynamic payoutPossible;

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
        payout = ((100) * self.betAmount / abs(pickOdds)) + self.betAmount;
    }
    return payout;
}

//deletes a bet
- (void) deleteBet  {
    //fetches bet
    ParseManager *parseManager = [ParseManager shared];
    [parseManager fetchBet:self withCompletion:^(PFObject * _Nonnull userBet, NSError * _Nonnull error) {
        if (userBet)    {
            //give the money back for the old bet
            int betsMade = [[PFUser.currentUser objectForKey:@"betsMade"] intValue];
            [PFUser.currentUser setValue: [NSNumber numberWithInt:(betsMade - 1)] forKey:@"betsMade"];
            NSLog(@"%d", betsMade);
            [userBet deleteInBackground];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void) lostBet {
    ParseManager *parseManager = [ParseManager shared];
    [parseManager fetchBet:self withCompletion:^(PFObject * _Nonnull userBet, NSError * _Nonnull error) {
        if (userBet)    {
            self.didWinBet = false;
            self.payout = 0.0;
        }
    }];
}

-(void) wonBet{
    ParseManager *parseManager = [ParseManager shared];
    [parseManager fetchBet:self withCompletion:^(PFObject * _Nonnull userBet, NSError * _Nonnull error) {
        if (userBet)    {
            //set payout to the possible payout and set didWin to true
            self.didWinBet = true;
            self.payout = self.payoutPossible;
            
            PFUser *user = [PFUser currentUser];
            int betsWon = [[PFUser.currentUser objectForKey:@"betsWon"] intValue];
            userBet[@"payout"] = [NSNumber numberWithDouble:self.payout];
            user[@"betsWon"] = [NSNumber numberWithInt:(betsWon + 1)];
            
            double bank = [[PFUser.currentUser objectForKey:@"bank"] intValue];
            user[@"bank"] = [NSNumber numberWithDouble:(bank + self.payout)];
            
            [userBet saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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
