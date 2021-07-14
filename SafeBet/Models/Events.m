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
        
        if ([name1 isEqualToString:self.team1]) {
            self.team1Odds = (int) odd1[@"price"];
            self.team2Odds = (int) odd2[@"price"];
        }   else {
            self.team2Odds = (int) odd1[@"price"];
            self.team2Odds = (int) odd2[@"price"];
        }
        
        NSString *gameDate = dictionary[@"commence_time"];
        NSLog(@"%@", gameDate);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setLocale: [NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//        formatter.dateFormat = @"yyyy-MM-dd";
        
        self.gameDate = [formatter dateFromString: gameDate];
        NSLog(@"%@", self.gameDate);
        
        NSDate *date = [formatter dateFromString:gameDate];
        NSLog(@"%@", date);
        
        int gameHour = self.gameDate.hour;
        int gameMinute = self.gameDate.minute;
        
        NSString *am = @" AM";
        NSString *pm = @" PM";
        if (gameHour > 12) {
            gameHour = gameHour - 12;
            self.time = [NSString stringWithFormat:@"%d%@%d%@", gameHour, @":", gameMinute, pm];
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
        for (NSDictionary *dictionary in dictionaries) {
            Events *event = [[Events alloc] initWithDictionary:dictionary];
            [events addObject:event];
        }
        return events;
}

@end
