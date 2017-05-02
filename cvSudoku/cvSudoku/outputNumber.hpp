//
//  outputNumber.hpp
//  digitRecognizer
//
//  Created by Sun Xi on 12/04/2017.
//  Copyright © 2017 SUNXI. All rights reserved.
//

#ifndef outputNumber_hpp
#define outputNumber_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/ml/ml.hpp"
#include <stdlib.h> // Include the standard library

using namespace cv;
using namespace std;

int recognize(Mat input, DigitRecognizer *dr, int kk, int i, int j); //string imgPath, string lbPath
Mat crop_image(Mat input);

#endif /* outputNumber_hpp */
