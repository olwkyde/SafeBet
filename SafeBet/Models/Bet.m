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

+(void) postBet: ( NSString * _Nullable )withTeam1 withTeam2: ( NSString * _Nullable )team2 withGameDate: (NSDate * _Nullable)gameDate withTeam1Odds: ( int * _Nullable )team1Odds  withTeam2Odds: ( int * _Nullable )team2Odds withTeam1Image: ( UIImage * _Nullable )image1 withTeam2Image: ( UIImage * _Nullable )image2 withBetAmount: ( int * _Nullable )betAmount  withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Bet *newBet = [Bet new];
    newBet.team1image = [self getPFFileFromImage:image1];
    newBet.team2image = [self getPFFileFromImage:image2];
    newBet.author = [PFUser currentUser];
    
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
