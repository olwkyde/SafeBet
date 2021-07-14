//
//  Event.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Events : NSObject

@property (nonatomic, strong) NSString *team1; // The name of the first team/fighter/competitor
@property (nonatomic, strong) NSString *team2; // The name of the second team/fighter/competitor
@property (nonatomic, strong) NSDate *gameDate; // the date of the game
@property (nonatomic, strong) NSString *date; //the day the match/competition/fight is
@property (nonatomic, strong) NSString *time; //the time of the day the match/competition/fight is
@property (nonatomic) int *team1Odds; //the Head to Head odds for the first team
@property (nonatomic) int *team2Odds; //the Head to Head odds for the second team
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries;
@end

NS_ASSUME_NONNULL_END
