//
//  FrictViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/22/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FrictViewController : UIViewController <MKMapViewDelegate>
{
    
    IBOutlet UIButton *searchButton;
    IBOutlet MKMapView *mapView;
    IBOutlet UIImageView *creatorStatusImage;
    IBOutlet UIImageView *statusImage;
    IBOutlet UILabel *nameText;
    IBOutlet UITextView *notesText;
    IBOutlet UILabel *dateRangeText;
    IBOutlet UIImageView *baseImageView;
    IBOutlet UILabel *scoreText;
    IBOutlet UILabel *ratingText;
    IBOutlet UIView *frictView;
    IBOutlet UIButton *creatorSwitch;
    IBOutlet UIButton *mateSwitch;
    IBOutlet UIButton *mapSwitch;
}

@property (readwrite, assign) NSUInteger frict_id;
@property (readwrite, assign) NSUInteger mate_id;
@property (readwrite, assign) NSUInteger request_id;
@property (readwrite, assign) NSUInteger creator;
@property (readwrite, assign) NSUInteger accepted;

@property (retain) MKPointAnnotation * pinToRemember;
@property (strong, nonatomic) IBOutlet UIButton *searchButtonPress;

- (IBAction)creatorButtonPress:(id)sender;
- (IBAction)mateButtonPress:(id)sender;
- (IBAction)mapButtonPress:(id)sender;



@end
