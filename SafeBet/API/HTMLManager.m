//
//  HTMLManager.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/27/21.
//

#import "HTMLManager.h"
#import <HTMLKit/HTMLKit.h>
#import "Bet.h"
#import "NSDate+DateTools.h"

@implementation HTMLManager

static NSString * const baseMLBURLString = @"https://www.baseball-reference.com/boxes/";

+ (instancetype)shared {
    static HTMLManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(void) fetchUFCPictureWithName:(nonnull NSString *)fighterName withCompletion:(void (^)(NSURL *url, NSError *error))completion   {
    //making the url endpoint out of the fighter name
    NSString *endpoint = [fighterName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSString *fullURLString = [@"https://www.ufc.com/athlete/" stringByAppendingString:endpoint];
    
    //make the HTML string from the URL
    NSURL *athleteURL = [NSURL URLWithString:fullURLString];
    NSError *urlError;
    NSStringEncoding encoding;
    
    NSString *athleteHTMLString = [[NSString alloc] initWithContentsOfURL:athleteURL usedEncoding:&encoding error:&urlError];
    
    //code for if the athlete HTML does not produce a string
    if (urlError != nil || athleteHTMLString == nil)    {
        completion(nil, urlError);
    }   else    {
        //instatiate through the HTML, and go through it's body
        HTMLDocument *document = [HTMLDocument documentWithString:athleteHTMLString];
        HTMLElement *body = document.body;
        
        //fetching the mobile image from the HTML body
        HTMLElement *mobileImageClass = [body querySelector:@"[class^='c-bio__image--mobile']"];
        
        //if it fetches a valid URL but there is no mobile Image
        if (mobileImageClass == nil)    {
            completion(nil, urlError);
        }   else{
            HTMLElement *mobileImagePicture = [mobileImageClass querySelector:@"img"];
            NSDictionary *attributes = mobileImagePicture.attributes;
            NSString *imageSource = attributes[@"src"];
            NSURL *imageSourceURL = [NSURL URLWithString:imageSource];
            completion(imageSourceURL, nil);
        }
    }
}

-(bool) didWinMLBBet:(Bet * _Nonnull)bet{
    if ([bet.betPick isEqualToString:[self findMLBWinnerWithBet:bet]])  {
        return true;
    }   return false;
}

-(NSString *) findMLBWinnerWithBet:(Bet * _Nonnull) bet    {
    //finding the month day and year of the game to put into the database
    int gameMonth = (int) bet.gameDate.month;
    int gameDay  = (int) bet.gameDate.day;
    int gameYear = (int) bet.gameDate.year;
    
    //initializing the team names
    NSString *team1 = bet.team1;
    NSString *team2 = bet.team2;
    
    //making a URL by concatening the integers with strings
    NSString *fullURLString = [@"https://www.baseball-reference.com/boxes/?month=" stringByAppendingFormat:@"%d%@%d%@%d", gameMonth, @"&day=", gameDay, @"&year=", gameYear];
    NSURL *mlbURL = [NSURL URLWithString:fullURLString];
    
    //creating an HTML file out of the URL
    NSStringEncoding encoding;
    NSError *error;
    NSString *mlbDatabaseHTML= [NSString stringWithContentsOfURL:mlbURL encoding:NSASCIIStringEncoding error:nil];
    
    
    //initializing an array of losers and a team game count (this is solely for the purpose of doubleheaders [2 games that happen on the same day])
    NSMutableArray *losers = [[NSMutableArray alloc] init];
    int teamGameCount = 0;
    NSString *firstGameURLString;
    NSString *secondGameURLString;
    
    //create an array of HTML elements including the losing team
    HTMLDocument *document = [HTMLDocument documentWithString:mlbDatabaseHTML];
    HTMLElement *body = document.body;
    NSArray *losingTeams = [body querySelectorAll:@"[class^='loser']"];
    
    //parsing through each losing team's HTML element
    for (HTMLElement *team in losingTeams)    {
        HTMLElement *teamTitle = [team querySelector:@"[href]"];
        NSString *parentNode = teamTitle.textContent;
        
        if ([parentNode isEqualToString:bet.betPick])  {
            teamGameCount++;
            //parsing to find the game link (in case there is sa doubleheader)
            HTMLElement *gameLink = [team querySelector:@"[class^='right gamelink']"];
            HTMLElement *gameLinkSource = [gameLink querySelector:@"[href]"];
            NSDictionary *gameDictionary = gameLinkSource.attributes;
            //assign a link to the doubleheader games
            if (teamGameCount == 1)   {
                firstGameURLString = gameDictionary[@"href"];
            }   else if (teamGameCount == 2){
                secondGameURLString = gameDictionary[@"href"];
            }
        }
        [losers addObject:parentNode];
    }
    
    //parsing through each winning team's HTML element
    NSMutableArray *winners = [[NSMutableArray alloc] init];
    NSArray *winningTeams = [body querySelectorAll:@"[class^='winner']"];
    
    for (HTMLElement *team in winningTeams)    {
        HTMLElement *teamTitle = [team querySelector:@"[href]"];
        NSString *parentNode = teamTitle.textContent;
        
        if ([parentNode isEqualToString:bet.betPick])  {
            teamGameCount++;
            //parsing to find the game link (in case there is sa doubleheader)
            HTMLElement *gameLink = [team querySelector:@"[class^='right gamelink']"];
            HTMLElement *gameLinkSource = [gameLink querySelector:@"[href]"];
            NSDictionary *gameDictionary = gameLinkSource.attributes;
            //assign a link to the doubleheader games
            if (teamGameCount == 1)   {
                firstGameURLString = gameDictionary[@"href"];
            }   else if (teamGameCount == 2){
                secondGameURLString = gameDictionary[@"href"];
            }
        }
        [winners addObject:parentNode];
    }
    
    //returns the game winner if there was only one game
    if (teamGameCount == 1) {
        if ([winners containsObject:team1])  {
            return team1;
        }   else{
            return team2;
        }
    }   else{
        NSURL *firstGameURL = [NSURL URLWithString:[baseMLBURLString stringByAppendingString:firstGameURLString]];
        NSURL *secondGameURL = [NSURL URLWithString:[baseMLBURLString stringByAppendingString:firstGameURLString]];
        NSArray *gameURLs = [NSArray arrayWithObjects:firstGameURL, secondGameURL, nil];
        return [self findMLBWinnerWithArrayLinks:gameURLs andDate:bet.gameDate];
    }
}

-(NSString *) findMLBWinnerWithArrayLinks:(NSArray * _Nonnull)arr andDate:(NSDate * _Nonnull)gameDate  {
    if (![[self findMLBWinnerWithLink:arr[1] andDate:gameDate] isEqualToString:@""]) {
        return [self findMLBWinnerWithLink:arr[1] andDate:gameDate];
    }   else if (![[self findMLBWinnerWithLink:arr[2] andDate:gameDate] isEqualToString:@""])   {
        return [self findMLBWinnerWithLink:arr[2] andDate:gameDate];
    }
    return @"";
}

-(NSString *) findMLBWinnerWithLink:(NSURL * _Nonnull)url andDate:(NSDate * _Nonnull)gameDate  {
    //get the HTML String from the url link
    NSStringEncoding encoding;
    NSError *error;
    NSString *gameHTMLString = [[NSString alloc] initWithContentsOfURL:url
                                                     usedEncoding:&encoding
                                                            error:&error];
    
    //parse the HTML for the time of the game
    HTMLDocument *document = [HTMLDocument documentWithString:gameHTMLString];
    HTMLElement *body = document.body;
    HTMLElement *scorebox = [body querySelector:@"[class^='scorebox']"];
    HTMLElement *scoreboxMeta = [scorebox querySelector:@"[class^='scorebox']"];
    HTMLElement *time = [scoreboxMeta querySelector:@"div"];
    
    //fetch the time strine
    NSString *timeContent = time.textContent;
    NSString *gameTimeString = [self fetchTimeFromText:(timeContent)];
    int eventHour = (int) gameDate.hour;
    
    //get the hour of the string
    NSRange gameRangeEnd = [gameTimeString rangeOfString:@":"];
    NSRange gameRange = NSMakeRange(0, (int) gameRangeEnd.location);
    int gameHour = [[gameTimeString substringWithRange:gameRange] intValue];
    
    //if the event is correct (if the time of the events is 1 hour off in either direction - done because the time starts are from different sources)
    if (abs(eventHour - gameHour) <= 1) {
        //grab team names
        NSArray *teamNameElements = [scorebox querySelectorAll:@"[itemprop^='name']"];
        
        //make an array for the team names, and add each team into it
        NSMutableArray *teamNames = [[NSMutableArray alloc] init];
        for (int i = 0; i < 2; i++)   {
            HTMLElement *teamNameElement = teamNameElements[i];
            [teamNames addObject:teamNameElement.textContent];
        }
        
        //make an array for the team scores, and add each team into it
        
        NSMutableArray *teamScores = [[NSMutableArray alloc] init];
        NSArray *scores = [scorebox querySelectorAll:@"[class^='scores']"];
        for (HTMLElement *score in scores)  {
            NSString *scoreTextMessedUp = score.textContent;
            
            [teamScores addObject:[NSNumber numberWithInt:[self fetchScoreFromText:scoreTextMessedUp]]];
        }
        //returns the teamName with the higher score
        if (teamScores[0] > teamScores[1])  {
            return teamNames[0];
        }   else{
            return teamNames[1];
        }
    }   else{
        //use the second game link if the first one is not the correct time
        return @"";
    }
}

//fetches the time from a weirdly formmated textString and returns it
-(NSString *) fetchTimeFromText:(NSString * _Nonnull)text{
    NSRange startTimeRange = [text rangeOfString:@"Start Time: "];
    int timeStartIndex = (int) (startTimeRange.location + startTimeRange.length);
    NSRange endTimeRange = [text rangeOfString:@".m."];
    int timeEndIndex = (int) endTimeRange.location;
    
    NSRange timeRange = NSMakeRange(timeStartIndex, (timeEndIndex-timeStartIndex));
    NSString *timeText = [text substringWithRange:timeRange];
    return [timeText stringByAppendingString:@".m."];
}

//fetches the score from a weirdly formmated textString and reutrns it
-(int) fetchScoreFromText:(NSString * _Nonnull)text {
    NSRange scoreRangeStart = [text rangeOfString:@"\n\t\t\t"];
    int scoreStartLocation = (int) (scoreRangeStart.location + scoreRangeStart.length);
    NSRange scoreRange = NSMakeRange(scoreStartLocation, 2);
    int score = [[text substringWithRange:scoreRange] intValue];
    
    if (score == 0 && [text characterAtIndex:scoreStartLocation] != 48) {
        scoreRange.location = 1;
        return [[text substringWithRange:scoreRange] intValue];
    } return score;
}

-(bool) didWinUFCBetWithBet:(Bet * _Nonnull)bet    {
    NSString *baseUFCURLString = @"https://www.ufc.com/athlete/";
    
    __block NSString *headShotSourceString = @"";
    [self fetchUFCPictureWithName:bet.betPick withCompletion:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
        if(url) {
            headShotSourceString = url.absoluteString;
        }   else{
            headShotSourceString = nil;
        }
    }];
    
    if (headShotSourceString)   {
        //make the website string out of the athlete name
        NSString *endpoint = [bet.betPick stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        NSURL *fullURL = [NSURL URLWithString:[baseUFCURLString stringByAppendingString:endpoint]];
        
        //make an HTML string out of the url
        NSString *athleteHTMLString = [NSString stringWithContentsOfURL:fullURL encoding:NSASCIIStringEncoding error:nil];
        
        HTMLDocument *document = [HTMLDocument documentWithString:athleteHTMLString];
        HTMLElement *body = document.body;
        
        //finds the first instance of the combatants' headshots in the fighter's last match
        HTMLElement *fighterAElement = [body querySelector:@"[class^='c-card-event--athlete-results__red-image']"];
        HTMLElement *fighterAPictureElement = [fighterAElement querySelector:@"img"];
        NSDictionary *fighterAattributes = fighterAPictureElement.attributes;
        NSString *fighterAPictureSourceString = fighterAattributes[@"src"];
        
        //finds the other instance of the combatants' headshots in the fighter's last match
        HTMLElement *fighterBElement = [body querySelector:@"[class^='c-card-event--athlete-results__blue-image']"];

        //checks which htmlelement has the headshot that is the same as the fighters' headshot
        HTMLElement *fighter = ([headShotSourceString isEqualToString:fighterAPictureSourceString])? fighterAElement: fighterBElement;
        
        //checks whether that headshot has the win plaque that is given to each winner
        HTMLElement *winPlaque = [fighter querySelector:@"[class^='c-card-event--athlete-results__plaque win']"];
        if (winPlaque)  {
            return true;
        }
        return false;
    }
    return false;
}

@end
