//
//  FrictDetailViewController.h
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrictDetailViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    IBOutlet UITextField *activeField;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITextField *firstNameText;
    IBOutlet UITextField *lastNameText;
    IBOutlet UISegmentedControl *genderSwitch;
    IBOutlet UISegmentedControl *baseSwitch;
    IBOutlet UIDatePicker *fromSwitch;
    IBOutlet UIDatePicker *toSwitch;
    IBOutlet UITextView *notes;
    IBOutlet UIButton *saveBtn;
}

//image view

@property (readwrite, assign) NSUInteger hu_id;
@property (nonatomic, weak) IBOutlet UISegmentedControl *visitedSegmentedControl;

- (IBAction)changeVisited;
- (IBAction)savePressed:(id)sender;

@end
