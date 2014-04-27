//
//  MateViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MateViewController : UIViewController {
    
    IBOutlet UILabel *sharedText;
    IBOutlet UIButton *sharedInfo;
    IBOutlet UIImageView *fieldImage;
    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *frictScore;
    IBOutlet UILabel *frictCount;
    IBOutlet UILabel *homeCount;
    IBOutlet UILabel *homeScore;
    IBOutlet UILabel *thirdCount;
    IBOutlet UILabel *thirdScore;
    IBOutlet UILabel *secondCount;
    IBOutlet UILabel *secondScore;
    IBOutlet UILabel *firstCount;
    IBOutlet UILabel *firstScore;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *editButton;
    IBOutlet UIButton *mapSwitch;
    IBOutlet UIButton *fieldSwitch;
}
- (IBAction)swipeRight:(id)sender;
- (IBAction)swipeLeft:(id)sender;

@property (readwrite, assign) NSUInteger request_id; //will be null if accepted is false
@property (readwrite, assign) NSUInteger hu_id; //mate id
@property (readwrite, assign) NSUInteger accepted; //1 if the mate accepted, 0 otherwise
@property (readwrite, assign) NSUInteger creator; //1 if coming from personal, 0 if coming from accepted
- (IBAction)sharedInfoPress:(id)sender;

- (IBAction)fieldSwitchSelected:(id)sender;
- (IBAction)mapSwitchSelected:(id)sender;


@property (retain) MKPointAnnotation * pinToRemember;


@end
