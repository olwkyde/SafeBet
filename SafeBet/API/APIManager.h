//
//  APIManager.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
NS_ASSUME_NONNULL_END

@interface APIManager : NSObject

+ (instancetype)shared;
- (void) fetchEventsWithCompletion: (void(^)(NSArray *events, NSError*)) completion;
- (void) fetchMLBEventsWithCompletion: (void(^)(NSArray *events, NSError*)) completion;
//- (void)fetchMLBPictures: (NSString * _Nullable)teamName withCompletion:(void (^)(NSURL *link, NSError *error))completion;

@end


