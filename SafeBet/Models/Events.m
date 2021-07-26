//
//  Event.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import "Events.h"
#import "NSDate+DateTools.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"


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
        
        //make the odds divisible by 10
        if ([name1 isEqualToString:self.team1]) {
            self.team1Odds = ([odd1[@"price"] intValue] / 10) * 10;
            self.team2Odds = ([odd2[@"price"] intValue] / 10) * 10;
        }   else{
            self.team1Odds = ([odd2[@"price"] intValue] / 10) * 10;
            self.team2Odds = ([odd1[@"price"] intValue] / 10) * 10;
        }
        
        NSString *gameDate = dictionary[@"commence_time"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        
        self.gameDate = [formatter dateFromString: gameDate];
        
        int gameHour = (int) self.gameDate.hour;
        int gameMinute = (int) self.gameDate.minute;
        
        NSString *am = @" AM";
        NSString *pm = @" PM";
        if (gameHour > 12) {
            gameHour = gameHour - 12;
            self.time = [NSString stringWithFormat:@"%d%@%02d%@", gameHour, @":", gameMinute, pm];
        }   else{
            self.time = [NSString stringWithFormat:@"%d%@%d%@", gameHour, @":", gameMinute, am];
        }
        
        int gameDay = (int) self.gameDate.day;
        int gameMonth = (int) self.gameDate.month;
        int gameYear = (((int) self.gameDate.year) % 100);
        
        
        self.date = [NSString stringWithFormat:@"%d%@%d%@%d", gameMonth, @"/", gameDay, @"/", gameYear];
        
        if ([self.sport isEqualToString:@"MLB"])   {            
            self.team1Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.team1]];
            self.team2Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.team2]];
        }
    }
    return self;
}


+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries{
        NSMutableArray *upcomingEvent = [NSMutableArray array];
        NSMutableArray *eventNextWeek = [NSMutableArray array];
        NSMutableArray *mainCards = [NSMutableArray array];
    
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
                if (numberOfDays <= 6)  {
                    [upcomingEvent addObject:event];
                }   else {
                    Events *event = [[Events alloc] initWithDictionary:dictionary];
                    [eventNextWeek addObject:event];
                }
            }
        }
    int upcomingEventCount = (upcomingEvent.count >= 5) ? 5 : upcomingEvent.count;
    NSRange rangeThisWeek = NSMakeRange(upcomingEvent.count - upcomingEventCount, (upcomingEventCount - 1));
    
    NSArray *upComingEventMainCard = [upcomingEvent subarrayWithRange:rangeThisWeek];
    
    
    int nextWeekEventsCount = (eventNextWeek.count >= 5) ? 5 : eventNextWeek.count;
    NSRange rangeNextWeek = NSMakeRange(eventNextWeek.count - nextWeekEventsCount, (nextWeekEventsCount - 1));
    NSArray *nextWeekEventMainCard = [eventNextWeek subarrayWithRange:rangeNextWeek];
    
    mainCards = [upComingEventMainCard arrayByAddingObjectsFromArray:nextWeekEventMainCard];
    return mainCards;
}


+ (NSMutableArray *)mlbEventsWithArray:(NSArray *)dictionaries{
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
            
            //checking if date is in the
            if (numberOfDays <= 2 || ([now compare:eventDate] == NSOrderedAscending)) {
                Events *event = [[Events alloc] initWithDictionary:dictionary];
                
                //filters out games with "huge underdogs". the API has some wacky odds for certain games.
                int underdogOdds = ((event.team1Odds > event.team2Odds) ? event.team1Odds: event.team2Odds);
                if (underdogOdds < 500) {
                    [events addObject:event];
                }
            }
        }
        return events;
}

//returns image resized
-(UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size  {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
