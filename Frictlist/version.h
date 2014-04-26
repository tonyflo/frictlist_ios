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

#define SCRIPTS_URL (@"http://frictlist.flooreeda.com/scripts/")
#define PLATFORM (1) //iOS
#define ZOOM (0.001)
#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.50
#define MAX_DEGREES_ARC 360

#endif

@end