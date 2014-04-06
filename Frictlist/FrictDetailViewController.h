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
    IBOutlet UISlider *ratingSlider;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UISegmentedControl *baseSwitch;
    IBOutlet UIDatePicker *fromSwitch;
    IBOutlet UITextView *notes;
    IBOutlet UIButton *saveBtn;
    IBOutlet UILabel *sliderText;
}

//image view

@property (readwrite, assign) NSUInteger frict_id;
@property (readwrite, assign) NSUInteger mate_id;
@property (readwrite, assign) NSUInteger creator;
@property (readwrite, assign) NSUInteger accepted;

- (IBAction)savePressed:(id)sender;


@end
