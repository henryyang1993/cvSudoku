//
//  digitRecognize.h
//  digitRecognizer
//
//  Created by Sun Xi on 04/04/2017.
//  Copyright © 2017 SUNXI. All rights reserved.
//

#ifndef digitRecognize_h
#define digitRecognize_h

#include <stdio.h>
#include <opencv2/opencv.hpp>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/ml/ml.hpp"


using namespace cv;

#define MAX_NUM_IMAGES 60000

typedef unsigned char BYTE;

class DigitRecognizer
{
public:
    DigitRecognizer();
    
    ~DigitRecognizer();
    
    bool train(char* trainPath, char* labelsPath);
    
    int classify(Mat img);
    
    
private:
    Mat preprocessImage(Mat img);
    
    int readFlippedInteger(FILE *fp);
    
private:
    KNearest *knn;
    int numRows, numCols, numImages;
    
    
};



#endif /* digitRecognize_h */

