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

    [self setUpViews];

}

//set custom border colors for all the views on this view controller
-(void) setUpViews  {
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

//performs action of logging in User
- (void)loginUser {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Sign Up"  message:@"Wrong username or password" preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // handle response here.
        }];
    //add the OK
    [alert addAction:okAction];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self presentViewController:alert animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];
        } else {
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"FeedSegue" sender:nil];
        }
    }];
}
@end
