//
//  MateDetailViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MateDetailViewController : UIViewController
{
    
    IBOutlet UITextField *firstNameText;
    IBOutlet UITextField *lastNameText;
    IBOutlet UISegmentedControl *genderSwitch;
    IBOutlet UIButton *saveButton;
}

@property (readwrite, assign) NSUInteger hu_id;
- (IBAction)savePressed:(id)sender;


@end
