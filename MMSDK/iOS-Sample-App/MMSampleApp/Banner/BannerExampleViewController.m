//
//  BannerExampleViewController.m
//  MMSampleApp
//
//
//  Copyright (c) 2010-2013 Millennial Media. All rights reserved.
//

#import "BannerExampleViewController.h"
#import "AppDelegate.h"

#define MILLENNIAL_IPHONE_AD_VIEW_FRAME CGRectMake(0, 0, 320, 50)
#define MILLENNIAL_IPAD_AD_VIEW_FRAME CGRectMake(0, 0, 728, 90)
#define MILLENNIAL_AD_VIEW_FRAME ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? MILLENNIAL_IPAD_AD_VIEW_FRAME : MILLENNIAL_IPHONE_AD_VIEW_FRAME)

@implementation BannerExampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Banner", @"Banner");
        self.tabBarItem.image = [UIImage imageNamed:@"TabBarBanner.png"];
    }
    return self;
}

#pragma mark - Get Ad

- (void)getAd {
    // Create an MMRequest object with location data
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MMRequest *request = [MMRequest requestWithLocation:appDelegate.locationManager.location];
    
    // Get a banner ad
    [_bannerAdView getAdWithRequest:request onCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"AD REQUEST SUCCEEDED");
            self.statusLabel.text = NSLocalizedString(@"Request succeeded", @"Request succeeded");
        }
        else {
            NSLog(@"AD REQUEST FAILED WITH ERROR %@", error);
            self.statusLabel.text = NSLocalizedString(@"Request failed", @"Request failed");
        }
    }];
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    [self getAd];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load our patterned image background (courtesy of SubtlePatterns.com)
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"broken_noise.png"]];
    
    // Notification will fire when an ad causes the application to terminate or enter the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminateFromAd:)
                                                 name:MillennialMediaAdWillTerminateApplication
                                               object:nil];
    
    // Notification will fire when an ad is tapped.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adWasTapped:)
                                                 name:MillennialMediaAdWasTapped
                                               object:nil];
    
    // Notification will fire when an ad modal will appear.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalWillAppear:)
                                                 name:MillennialMediaAdModalWillAppear
                                               object:nil];
    
    // Notification will fire when an ad modal did appear.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalDidAppear:)
                                                 name:MillennialMediaAdModalDidAppear
                                               object:nil];
    
    // Notification will fire when an ad modal will dismiss.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalWillDismiss:)
                                                 name:MillennialMediaAdModalWillDismiss
                                               object:nil];
    
    // Notification will fire when an ad modal did dismiss.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalDidDismiss:)
                                                 name:MillennialMediaAdModalDidDismiss
                                               object:nil];
    
    // Returns an autoreleased MMAdView object
    _bannerAdView = [[MMAdView alloc] initWithFrame:MILLENNIAL_AD_VIEW_FRAME
                                               apid:BANNER_APID
                                 rootViewController:self];
    
    // Ad banner to the view
    [self.view addSubview:_bannerAdView];
    
    // Refresh the ad every 30 seconds
    _timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                              target:self
                                            selector:@selector(getAd)
                                            userInfo:nil
                                             repeats:YES];
    // Fire the first ad request now
    [_timer fire];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Stop the timer
    [_timer invalidate];
    _timer = nil;
    
    // Remove notification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MillennialMediaAdWillTerminateApplication
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MillennialMediaAdWasTapped
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MillennialMediaAdModalWillAppear
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MillennialMediaAdModalDidAppear
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MillennialMediaAdModalWillDismiss
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MillennialMediaAdModalDidDismiss
                                                  object:nil];
    
    self.statusLabel = nil; // Release our status label
    _bannerAdView = nil; // Properly release MMAdView object
}

#pragma mark - Millennial Media Notification Methods

- (void)adWasTapped:(NSNotification *)notification
{
    NSLog(@"AD WAS TAPPED");
    NSLog(@"TAPPED AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"TAPPED AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"TAPPED AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
    
    if ([[notification userInfo] objectForKey:MillennialMediaAdObjectKey] == _bannerAdView) {
        NSLog(@"TAPPED AD IS THE _bannerAdView INSTANCE VARIABLE");
    }
}

- (void)applicationWillTerminateFromAd:(NSNotification *)notification
{
	NSLog(@"AD WILL OPEN SAFARI");
    // No User Info is passed for this notification
}

- (void)adModalWillDismiss:(NSNotification *)notification
{
	NSLog(@"AD MODAL WILL DISMISS");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

- (void)adModalDidDismiss:(NSNotification *)notification
{
	NSLog(@"AD MODAL DID DISMISS");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

- (void)adModalWillAppear:(NSNotification *)notification
{
	NSLog(@"AD MODAL WILL APPEAR");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

- (void)adModalDidAppear:(NSNotification *)notification
{
	NSLog(@"AD MODAL DID APPEAR");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
