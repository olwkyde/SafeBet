//
//  SignUpViewController.m
//  SafeBet
//
//  Created by Isaac Oluwakuyide on 7/10/21.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

//set custom border colors for all the views on this view controller
-(void) setupViews  {
    [self.usernameTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"placeholderLabel.textColor"];
    [self.passwordTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"placeholderLabel.textColor"];
    [self.confirmPasswordTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"placeholderLabel.textColor"];
    
    self.usernameTextField.layer.borderWidth = 0.3;
    self.passwordTextField.layer.borderWidth = 0.3;
    self.confirmPasswordTextField.layer.borderWidth = 0.3;
    
    self.usernameTextField.layer.cornerRadius = 5;
    self.passwordTextField.layer.cornerRadius = 5;
    self.confirmPasswordTextField.layer.cornerRadius = 5;
    self.signUpButton.layer.cornerRadius = 5;
    
    self.usernameTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.passwordTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.confirmPasswordTextField.layer.borderColor = [UIColor whiteColor].CGColor;
}
- (IBAction)signUpButtonPressed:(id)sender {
    
    //create an alert with message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in Signing Up" message:@"Username/Password is missing" preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    // handle response here.
    }];
    
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    if ([self usernameIsEmpty] || [self passwordIsEmpty])   {
        if ([self usernameIsEmpty])    {
            //change the alert message
            [alert setMessage:@"Usernames cannot be empty"];
            //present the alert
            [self presentViewController:alert animated:YES completion:^{
            }];
        }   else{
                //change the alert message
                [alert setMessage: @"Passwords cannot be empty"];
                //present the alert
                [self presentViewController:alert animated:YES completion:^{
                    // optional code for what happens after the alert controller has finished presenting
                }];
        }
    }   else if (!([self usernameIsEmpty] || [self passwordIsEmpty]) && ([self isUsernameTooLong] || [self usernameContainsInvalidSymbols] || [self usernameStartsWithInvalidSymbol] || [self passwordsDoNotMatch]))   {
        if ([self isUsernameTooLong])   {
            //change the alert message
            [alert setMessage:@"Username is too long."];
            //present the alert
            [self presentViewController:alert animated:YES completion:^{
            }];
        }   else if ([self usernameContainsInvalidSymbols]) {
            //change the alert message
            [alert setMessage:@"Usernames can only contain letters, numbers, periods, and underscores"];
            //present the alert
            [self presentViewController:alert animated:YES completion:^{
            }];
        }   else if ([self usernameStartsWithInvalidSymbol])  {
            //change the alert message
            [alert setMessage:@"Usernames cannot start with a period"];
            //present the alert
            [self presentViewController:alert animated:YES completion:^{
            }];
        }   else if ([self passwordsDoNotMatch])    {
            //change the alert message
            [alert setMessage:@"Passwords do not match"];
            //present the alert
            [self presentViewController:alert animated:YES completion:^{
            }];
        }
    }
    else{
        [self registerUser];
    }
}

//checks if username input length is over 30 characters
- (BOOL) isUsernameTooLong    {
    if ([self.usernameTextField.text length] >= 30) {return true;}
    return false;
}

//checks if username contains invalid symbols (usernames should only have letters, numbers, periods, and undescores)
- (BOOL) usernameContainsInvalidSymbols {
    NSString *username = self.usernameTextField.text;
    if ([username containsString:@","] || [username containsString:@"/"] || [username containsString:@":"] || [username containsString:@";"] || [username containsString:@"\""] || [username containsString:@"\\"] || [username containsString:@"'"] || [username containsString:@"|"] || [username containsString:@","] || [username containsString:@"{"] || [username containsString:@"["] || [username containsString:@"}"] || [username containsString:@"]"] || [username containsString:@"!"] || [username containsString:@"@"] || [username containsString:@"#"] || [username containsString:@"$"] || [username containsString:@"%"] || [username containsString:@"^"] || [username containsString:@"&"] || [username containsString:@"*"] || [username containsString:@"("] || [username containsString:@")"] || [username containsString:@"-"] || [username containsString:@"+"] || [username containsString:@"="] || [username containsString:@"`"] || [username containsString:@"~"])   {
        return true;
    }
    return false;
}

//checks if username starts with a period
-(BOOL) usernameStartsWithInvalidSymbol {
    if ([self.usernameTextField.text characterAtIndex:0] == '.')    {
        return true;
    }
    return false;
}

//checks if username field is empty
-(BOOL) usernameIsEmpty {
    if ([self.usernameTextField.text isEqual:@""])  {
        return true;
    } return false;
}

//checks if password field is empty
-(BOOL) passwordIsEmpty {
    if ([self.passwordTextField.text isEqual:@""])  {
        return true;
    } return false;
}

//checks if passwords do not match
-(BOOL) passwordsDoNotMatch {
    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text])    {
        return true;
    }
    return false;
}

//creates a new user
- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameTextField.text;
    newUser.password = self.passwordTextField.text;
    
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            
            LoginViewController * loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            //present that view controller
            [self presentViewController:loginViewController animated:YES completion:nil];
        }
    }];
}

@end
