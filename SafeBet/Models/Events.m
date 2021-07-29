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
#import "HTMLManager.h"


@implementation Events


-(instancetype)initWithDictionary:(NSDictionary *)dictionary   {
    self = [super init];
    if (self)   {
        self.sport = dictionary[@"sport_title"];
        self.team1 = dictionary[@"home_team"];
        self.team2 = dictionary[@"away_team"];
        
        //fetching the odds from the dictionary
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
        
        //fetching minute and hour for NSDate to display the time
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
        
        //fetching the day month and year to display the day of the game
        int gameDay = (int) self.gameDate.day;
        int gameMonth = (int) self.gameDate.month;
        int gameYear = (((int) self.gameDate.year) % 100);
        
        
        self.date = [NSString stringWithFormat:@"%d%@%d%@%d", gameMonth, @"/", gameDay, @"/", gameYear];
        
        //fetching MLB team logos from Assets
        if ([self.sport isEqualToString:@"MLB"])   {            
            self.team1Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.team1]];
            self.team2Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.team2]];
        }   else{
            //fetching UFC fighter images
            HTMLManager *html = [HTMLManager shared];
            [html fetchUFCPictureWithName:self.team1 withCompletion:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
                if (url == nil)    {
                    self.team1Image.image = [UIImage imageNamed:@"placeholder profile"];
                }   else{
                    NSData *team1ImageData = [[NSData alloc] initWithContentsOfURL:url];
                    UIImage *team1Image = [UIImage imageWithData:team1ImageData];
                    self.team1Image = [[UIImageView alloc] initWithImage:team1Image];
                    
                }
            }];
            [html fetchUFCPictureWithName:self.team2 withCompletion:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
                if (url == nil)    {
                    self.team1Image.image = [UIImage imageNamed:@"placeholder profile"];
                }   else{
                    NSData *team2ImageData = [[NSData alloc] initWithContentsOfURL:url];
                    UIImage *team2Image = [UIImage imageWithData:team2ImageData];
                    self.team2Image = [[UIImageView alloc] initWithImage:team2Image];
                }
            }];
        }
    }
    return self;
}

+ (NSMutableArray *)ufcEventsWithArray:(NSArray *)dictionaries{
        //create "main card" arrays out of the entries; these will be the last five events of a given night, generally considered the most important and the ones wortwhile to bet on
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
        //counts whether there are at least 5 events returned by the array, if so, take the last 5, if not, take all
        int upcomingEventCount = (upcomingEvent.count >= 5) ? 5 : upcomingEvent.count;
        NSRange rangeThisWeek = NSMakeRange(upcomingEvent.count - upcomingEventCount, (upcomingEventCount - 1));
    
        NSArray *upComingEventMainCard = [upcomingEvent subarrayWithRange:rangeThisWeek];
        
    
        int nextWeekEventsCount = (eventNextWeek.count >= 5) ? 5 : eventNextWeek.count;
        NSRange rangeNextWeek = NSMakeRange(eventNextWeek.count - nextWeekEventsCount, (nextWeekEventsCount - 1));
        NSArray *nextWeekEventMainCard = [eventNextWeek subarrayWithRange:rangeNextWeek];
    
        //add last 5 or less events into the array
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
            
            //checking if date is in the future but less than 2 days apart
            if (numberOfDays <= 2 && (round(secondsBetween) >= 0)) {
                Events *event = [[Events alloc] initWithDictionary:dictionary];
                
                //filters out games with "huge underdogs". the API has wacky odds for certain games.
                int underdogOdds = ((event.team1Odds > event.team2Odds) ? event.team1Odds: event.team2Odds);
                if (abs(underdogOdds)  < 500) {
                    [events addObject:event];
                }
            }
        }
        return events;
}

//returns image resized with size parameter
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
