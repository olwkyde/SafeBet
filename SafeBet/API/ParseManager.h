//
//  ParseManager.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/30/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Bet.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseManager : NSObject

+ (instancetype)shared;
-(void)fetchUserBetsWithCompletion:(void (^)(NSArray *betsPlaced, NSError *error))completion;
-(void) fetchBet:(Bet * _Nonnull)bet withCompletion:(void (^)(PFObject *userBet, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
