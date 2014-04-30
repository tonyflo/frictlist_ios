//
//  BannerExampleViewController.h
//  MMSampleApp
//
//
//  Copyright (c) 2010-2013 Millennial Media. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MillennialMedia/MMAdView.h>

@interface BannerExampleViewController : UIViewController {
    MMAdView *_bannerAdView;
    NSTimer *_timer;
}

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

- (IBAction)refresh:(id)sender;

@end
