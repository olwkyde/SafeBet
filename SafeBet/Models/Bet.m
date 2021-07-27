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
    newBet.betPick = betPick;
    newBet.gameDate = event.gameDate;
    newBet.team1 = event.team1;
    newBet.team1Odds = event.team1Odds;
    newBet.team1image = [self getPFFileFromImage:event.team1Image.image];
    newBet.team2 = event.team2;
    newBet.team2Odds = event.team2Odds;
    newBet.team2image = [self getPFFileFromImage:event.team2Image.image];
    
    [newBet saveInBackgroundWithBlock:completion];
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
