//
//  Bet.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/20/21.
//

#import <Parse/Parse.h>
#import "Events.h"

NS_ASSUME_NONNULL_BEGIN

@interface Bet : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *team1; // The name of the first team/fighter/competitor
@property (nonatomic, strong) NSString *team2; // The name of the second team/fighter/competitor
@property (nonatomic, strong) NSDate *gameDate; // the date of the game
@property (nonatomic, strong) NSString *date; //the day the match/competition/fight is
@property (nonatomic, assign) int team1Odds; //the Head to Head odds for the first team
@property (nonatomic, assign) int team2Odds; //the Head to Head odds for the second team
@property (nonatomic, strong) PFFileObject *team1image; // the picture for the first team
@property (nonatomic, strong) PFFileObject *team2image; // the picture for the first team
@property (nonatomic, assign) double betAmount; //amount the user bet
@property (nonatomic, assign) bool *didWinBet; //whether user won the bet
@property (nonatomic, strong) NSString *betPick; //team user bets to win
@property (nonatomic, assign) double payout; //the payout that is possible
@property (nonatomic, strong) NSArray *userBets;

+(void) postBetWithEvent: ( Events * _Nonnull )event withBetAmount: (double)betAmount withBetPick: (NSString * _Nonnull)betPick withCompletion: (PFBooleanResultBlock  _Nullable)completion;
- (void) deleteBet;
@end

NS_ASSUME_NONNULL_END
