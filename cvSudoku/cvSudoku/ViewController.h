//
//  ViewController.h
//  My_Camera_App
//
//  Created by YANGHANYU on 1/31/17.
//  Copyright © 2017 YANGHANYU. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#import "opencv2/opencv.hpp"
#import "opencv2/highgui/ios.h"
#endif

@interface ViewController : UIViewController<CvPhotoCameraDelegate>


@end

