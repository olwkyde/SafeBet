//
//  HTMLManager.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/27/21.
//

#import <Foundation/Foundation.h>
#import "Bet.h"


NS_ASSUME_NONNULL_BEGIN

@interface HTMLManager : NSObject

+ (instancetype)shared;
-(void) fetchUFCPictureWithName:(nonnull NSString *)fighterName withCompletion:(void (^)(NSURL *url, NSError *error))completion;
-(bool) didWinMLBBet:(Bet * _Nonnull)bet;

@end

NS_ASSUME_NONNULL_END
