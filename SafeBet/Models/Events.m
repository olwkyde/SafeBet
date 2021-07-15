//
//  Event.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import "Events.h"
#import "NSDate+DateTools.h"

@implementation Events

-(instancetype)initWithDictionary:(NSDictionary *)dictionary   {
    self = [super init];
    if (self)   {
        self.sport = dictionary[@"sport_title"];
        self.team1 = dictionary[@"home_team"];
        self.team2 = dictionary[@"away_team"];
        
        NSArray *bookmakers = dictionary[@"bookmakers"];
        NSDictionary *bookmaker = [bookmakers objectAtIndex:0];
        NSArray *markets = bookmaker[@"markets"];
        NSDictionary *market = [markets objectAtIndex:0];
        NSArray *outcomes = market[@"outcomes"];
        
        NSDictionary *odd1 = [outcomes objectAtIndex:0];
        NSDictionary *odd2 = [outcomes objectAtIndex:1];
        
        NSString *name1 = odd1[@"name"];
        
//        if ([name1 isEqualToString:self.team1]) {
//            self.team1Odds = (double) odd1[@"price"];
//            self.team2Odds = (double) odd2[@"price"];
//        }   else {
//            self.team2Odds = (double) odd1[@"price"];
//            self.team1Odds = (double) odd2[@"price"];
//        }
        
        if ([name1 isEqualToString:self.team1]) {
            self.team1Odds = ([odd1[@"price"] intValue] / 10) * 10;
            self.team2Odds = ([odd2[@"price"] intValue] / 10) * 10;
        }   else{
            self.team1Odds = ([odd2[@"price"] intValue] / 10) * 10;
            self.team2Odds = ([odd1[@"price"] intValue] / 10) * 10;
        }
        
        NSString *gameDate = dictionary[@"commence_time"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setLocale: [NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//        formatter.dateFormat = @"yyyy-MM-dd";
        
        self.gameDate = [formatter dateFromString: gameDate];
        
        int gameHour = self.gameDate.hour;
        int gameMinute = self.gameDate.minute;
        
        
        
        NSString *am = @" AM";
        NSString *pm = @" PM";
        if (gameHour > 12) {
            gameHour = gameHour - 12;
            self.time = [NSString stringWithFormat:@"%d%@%02d%@", gameHour, @":", gameMinute, pm];
        }   else{
            self.time = [NSString stringWithFormat:@"%d%@%d%@", gameHour, @":", gameMinute, am];
        }
        
        int gameDay = self.gameDate.day;
        int gameMonth = self.gameDate.month;
        int gameYear = (self.gameDate.year % 100);
        
        self.date = [NSString stringWithFormat:@"%d%@%d%@%d", gameMonth, @"/", gameDay, @"/", gameYear];
    }
    return self;
}

+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries{
        NSMutableArray *events = [NSMutableArray array];
    
        NSDate *now = [NSDate date];
    
        for (NSDictionary *dictionary in dictionaries) {
            
            //finding the amount of time between now and the commence time to filter events that are too far out in the future
            NSString *eventDateString = dictionary[@"commence_time"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
            NSDate *eventDate = [formatter dateFromString: eventDateString];
            
            NSTimeInterval secondsBetween = [eventDate timeIntervalSinceDate:now];
            int numberOfDays = secondsBetween / 86400;
            
            if (numberOfDays <= 13) {
                Events *event = [[Events alloc] initWithDictionary:dictionary];
                [events addObject:event];
            }
        }
        return events;
}

@end
