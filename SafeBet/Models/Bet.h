//
//  Bet.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Bet : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *team1; // The name of the first team/fighter/competitor
@property (nonatomic, strong) NSString *team2; // The name of the second team/fighter/competitor
@property (nonatomic, strong) NSDate *gameDate; // the date of the game
@property (nonatomic, strong) NSString *date; //the day the match/competition/fight is
@property (nonatomic, assign) int *team1Odds; //the Head to Head odds for the first team
@property (nonatomic, assign) int *team2Odds; //the Head to Head odds for the second team
@property (nonatomic, strong) PFFileObject *team1image; // the picture for the first team
@property (nonatomic, strong) PFFileObject *team2image; // the picture for the first team
@property (nonatomic, assign) int *betAmount;

+(void) postBet: ( NSString * _Nullable )withTeam1 withTeam2: ( NSString * _Nullable )team2 withGameDate: (NSDate * _Nullable)gameDate withTeam1Odds: ( int * _Nullable )team1Odds  withTeam2Odds: ( int * _Nullable )team2Odds withTeam1Image: ( UIImage * _Nullable )image1 withTeam2Image: ( UIImage * _Nullable )image2 withBetAmount: ( int * _Nullable )betAmount  withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
