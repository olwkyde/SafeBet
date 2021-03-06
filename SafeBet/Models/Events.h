//
//  Event.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Events : NSObject

@property (nonatomic, strong) NSString *team1; // The name of the first team/fighter/competitor
@property (nonatomic, strong) NSString *team2; // The name of the second team/fighter/competitor
@property (nonatomic, strong) NSDate *gameDate; // the date of the game
@property (nonatomic, strong) NSString *date; //the day the match/competition/fight is
@property (nonatomic, strong) NSString *time; //the time of the day the match/competition/fight is
@property (nonatomic, assign) int *team1Odds; //the Head to Head odds for the first team
@property (nonatomic, assign) int *team2Odds; //the Head to Head odds for the second team
@property (nonatomic, strong) NSString *sport;
@property (nonatomic, strong) UIImageView *team1Image; // the image for the first team/fighter/competitor
@property (nonatomic, strong) UIImageView *team2Image; // the image for the second team/fighter/competitor
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray *)ufcEventsWithArray:(NSArray *)dictionaries;
+ (NSMutableArray *)mlbEventsWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
