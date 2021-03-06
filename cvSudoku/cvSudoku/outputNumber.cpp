//
//  outputNumber.cpp
//  digitRecognizer
//
//  Created by Sun Xi on 12/04/2017.
//  Copyright © 2017 SUNXI. All rights reserved.
//

#include "digitRecognize.h"
#include <stdio.h>
#include <stdlib.h> // Include the standard library
#include <unistd.h>

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>


using namespace cv;
using namespace std;

Mat crop_image (Mat input) {
    Mat cropped;
    int crop_w;
    int crop_h;
    if (input.rows > 120 && input.cols > 125) {
        crop_w = input.rows-80;
        crop_h = input.cols-10;
        int x = input.cols/2 - crop_h/2;
        int y = input.rows/2 - crop_w/2;
        Rect roi(x, y, crop_h, crop_w);
        Mat croppedRef(input, roi);
        croppedRef.copyTo(cropped);
        //cropped = input(Rect(x, y, crop_h, crop_w));
        
    } else {
        cropped = input;
    }
    return cropped;
}

int recognize(Mat input, DigitRecognizer *dr, int kk, int i, int j) { //string imgPath, string lbPath
    

    Mat cropped;
//    cropped = crop_image(input);
    cropped = input;
    GaussianBlur(cropped, cropped, Size(11, 11), 0);
    
    //std::cout << "path to image: " << imgPath << std::endl;
    Mat cvOld;
    resize(cropped, cvOld, Size(28, 28));
    
//    cvOld = cropped; //imread(imgPath, CV_8UC1); //change the directory
    Mat cvaThreshold = cvOld.clone();
    Mat cvThreshold = cvOld.clone();
    adaptiveThreshold(cvOld, cvaThreshold, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY_INV, 101, 1.0);
    threshold(cvOld, cvThreshold, 150, 255, THRESH_BINARY_INV);
    
    
    int count = 0;
    for (int i = 0; i < cvThreshold.rows; i++) {
        for (int j = 0; j < cvThreshold.cols; j++) {
            if (i < 2 || j < 2 || i >= cvThreshold.rows - 2 || j >= cvThreshold.cols - 2) {
                cvThreshold.at<uchar>(i, j) = 0;
                cvaThreshold.at<uchar>(i, j) = 0;
            }
            if (cvThreshold.at<uchar>(i, j) == 0)
                count++;
        }
    }
    
    cout << "cvaThreshold" << endl;
    cout << cvaThreshold << endl;

    cout << "cvThreshold" << endl;
    cout << cvThreshold << endl;
//
//    char filename[100];
//    sprintf(filename, "/Users/yanghanyu/github/CMU_16423_CVAPPS/cvSudoku/cvSudoku/test/%d%d%d.jpg", kk, i, j);
//    imwrite(filename, cvaThreshold);
    
    double black_pixels = 1 - count/(double)(cvThreshold.rows*cvThreshold.cols);
    cout << "black percentage: " << black_pixels << endl;
    //DigitRecognizer *dr = new DigitRecognizer();
    
    //const char *trainImgPath = imgPath.c_str();
    //const char *trainLbPath = lbPath.c_str();

    
    //bool b = dr->train(trainImgPath, trainLbPath);
    
    if (black_pixels < 0.05) {
        return -1;
    } else {
        int dist = cvaThreshold.rows;
        cv::Mat cell = cv::Mat(cv::Size(dist, dist), CV_8UC1);
        
        
        for (int y = 0; y < dist; y++) {
            uchar* ptr = cell.ptr(y);
            for (int x = 0; x < dist; x++) {
                ptr[x] = cvaThreshold.at<uchar>(y, x);
            }
        }
        std::cout << cvaThreshold.rows << " " << cvaThreshold.cols << std::endl;
        
        int number = dr->classify(cell);

        return number;
    }
}

