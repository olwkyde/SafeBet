//
//  ProfileViewController.h
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/24/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *betsMadeLabel;
@property (weak, nonatomic) IBOutlet UILabel *betsWonLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankLabel;


-(void) profileImageTapped;
@end

NS_ASSUME_NONNULL_END
