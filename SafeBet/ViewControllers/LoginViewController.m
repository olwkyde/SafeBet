//
//  LoginViewController.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/9/21.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setViewConstraints];

}

//set custom border colors for all the views on this view controller
-(void) setViewConstraints  {
    //make the placehlder text white
    [self.usernameTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"placeholderLabel.textColor"];
    [self.passwordTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"placeholderLabel.textColor"];
    
    //set a textField border width
    self.usernameTextField.layer.borderWidth = 0.3;
    self.passwordTextField.layer.borderWidth = 0.3;
    
    //curve the textField border
    self.usernameTextField.layer.cornerRadius = 5;
    self.passwordTextField.layer.cornerRadius = 5;
    self.loginButton.layer.cornerRadius = 5;
    
    //set the textField border color
    self.usernameTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.passwordTextField.layer.borderColor = [UIColor whiteColor].CGColor;
}
- (IBAction)loginPressed:(id)sender {
    [self loginUser];
}


- (void)loginUser {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"FeedSegue" sender:nil];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
