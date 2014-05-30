//
//  version.h
//  Frictlist
//
//  Created by Tony Flo on 12/27/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#ifndef Frictlist_version_h
#define Frictlist_version_h

@interface version : NSObject
{

}

//comment for releases
#define NON_PRODUCTION

#define SCRIPTS_URL (@"http://frictlist.flooreeda.com/scripts/")
#define PLATFORM (1) //iOS
#define ZOOM (0.001)
#define RED (33.0/255.0f)
#define GREEN (255.0/255.0f)
#define BLUE (0.0/255.0f)
#define TAB_BAR_HEIGHT (30)

#define AD_BANNER_HEIGHT (49)
#define TOP_LAYER (100)

#if defined(MMEDIA)
#define APID_BANNER_FRICTLIST (@"160612")
#define APID_BANNER_MATELIST (@"160610")
#define APID_INTERSTATIAL_ADD_FRICT (@"161158")
#define APID_INTERSTATIAL_ADD_MATE (@"161159")
#endif

#define MAX_EMAIL_LENGTH (35)
#define MAX_NAME_LENGTH (50)
#define MIN_USERNAME_LENGTH (6)
#define MAX_USERNAME_LENGTH (20)
#define MIN_PASSWORD_LENGTH (6)
#define MAX_PASSWORD_LENGTH (255)
#define AGE_LIMIT (14)

#define STATUS_BAR_HEIGHT (50)

#define TERMS_LABEL_SIGN_IN (@"By clicking Sign In, you agree to the")
#define TERMS_LABEL_CREATE_ACCOUNT (@"By clicking Create Account, you agree to the")

//choose ad service
#define REVMOB (1)
//#define MMEDIA (1)

#if defined(REVMOB)
#define REVMOB_APP_ID (@"5387b9942a709ab206a8166f")
#define REVMOB_MATELIST_BANNER_ID (@"5387ba712a709ab206a8167d")
#define REVMOB_FRICTLIST_BANNER_ID (@"5387ba5a2a709ab206a8167b")
#define REVMOB_MATE_DETAIL_FULLSCREEN_ID (@"5387b9942a709ab206a8166f")
#define REVMOB_FRICT_DETAIL_FULLSCREEN_ID (@"5387ba102a709ab206a81679")
#endif

#endif

@end