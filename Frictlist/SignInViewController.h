//
//  SignInViewController.h
//  Frictlist
//
//  Created by Tony Flo on 1/2/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController<UITextFieldDelegate>
{
    BOOL checkboxSelected;
    IBOutlet UIButton *checkboxButton;
    IBOutlet UITextField *passwordText;
    IBOutlet UITextField *emailText;
    IBOutlet UISegmentedControl *genderSwitch;
    IBOutlet UIDatePicker *birthdatePicker;
    IBOutlet UITextField *firstNameText;
    IBOutlet UITextField *lastNameText;
}

@property (strong, nonatomic) IBOutlet UINavigationItem *bakcButton;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;

- (IBAction)checkboxButton:(id)sender;
- (IBAction)signInButtonClick:(id)sender;
- (IBAction)backButonClick:(id)sender;

@end
