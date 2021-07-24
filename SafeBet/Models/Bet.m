//
//  Bet.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import "Bet.h"
#import <Parse/Parse.h>


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
    newBet.team1image = [self getPFFileFromImage:event.team1Image];
    newBet.team2 = event.team2;
    newBet.team2Odds = event.team2Odds;
    newBet.team2image = [self getPFFileFromImage:event.team2Image];
    
    [newBet saveInBackgroundWithBlock:completion];
}

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
