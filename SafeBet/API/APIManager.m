//
//  APIManager.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import "APIManager.h"
#import "Events.h"

static NSString * const baseURLString = @"https://the-odds-api.com/liveapi/guides/v4/";

@implementation APIManager


+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSString *) getAPIKey {
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"TheOddsAPIKeys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"API_KEY"];
    
    return key;
}

- (void)fetchEventsWithCompletion:(void (^)(NSArray *events, NSError *error))completion {
    //get the bets from endpoint
    NSString *key = [self getAPIKey];
    NSString *endpoint = @"https://api.the-odds-api.com/v4/sports/mma_mixed_martial_arts/odds/?regions=us&markets=h2h,spreads&oddsFormat=american&apiKey=";
    
    NSString *urlString = [endpoint stringByAppendingString:key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               completion(nil, error);
           }
           else {
               NSArray *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSMutableArray *events = [Events eventsWithArray:dataDictionary];
               completion(events, nil);

           }
       }];
    [task resume];
}
@end
