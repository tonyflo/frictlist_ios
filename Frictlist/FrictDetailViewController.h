//
//  FrictDetailViewController.h
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FrictDetailViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    IBOutlet UISlider *ratingSlider;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UISegmentedControl *baseSwitch;
    IBOutlet UIDatePicker *fromSwitch;
    IBOutlet UITextView *notes;
    IBOutlet UIButton *saveBtn;
    IBOutlet UILabel *sliderText;
    IBOutlet UISegmentedControl *locationToggle;
}

//image view

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (readwrite, assign) NSUInteger frict_id;
@property (readwrite, assign) NSUInteger mate_id;
@property (readwrite, assign) NSUInteger creator;
@property (readwrite, assign) NSUInteger accepted;

@property (retain) MKPointAnnotation * pinToRemember;

- (IBAction)savePressed:(id)sender;
-(IBAction)locationToggled:(id)sender;
@end
