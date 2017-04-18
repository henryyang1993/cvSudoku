//
//  ViewController.m
//  digitRecognizer
//
//  Created by Sun Xi on 04/04/2017.
//  Copyright © 2017 SUNXI. All rights reserved.
//

#import "ViewController.h"

#ifdef __cplusplus
#include <opencv2/opencv.hpp> // Includes the opencv library
#include <stdlib.h> // Include the standard library
#include "armadillo" // Includes the armadillo library
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/nonfree/features2d.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <opencv2/legacy/legacy.hpp>
#include "digitRecognize.h"
#include "outputNumber.hpp"
#include <math.h>
#endif


@interface ViewController () {
    // Setup the view
    UIImageView *imageView_;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //UIImage *image = [UIImage imageNamed:@"digit_4.jpg"];
    NSString *imageDirectory = @"digit_4.jpg";
    std::string imageDir = std::string([imageDirectory UTF8String]);
    
    //imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    
    // Ensure aspect ratio looks correct
    //imageView_.contentMode = UIViewContentModeScaleAspectFit;
    
    //[self.view addSubview:imageView_];
    //cv::Mat cvImage = [self cvMatFromUIImage:image];
    //cv::Mat gray; cv::cvtColor(cvImage, gray, CV_RGBA2GRAY);
    
    //cv::Mat display_im; cv::cvtColor(gray,display_im,CV_GRAY2BGR); // Get the display image
    
    //cv::Mat cvOld = cv::Mat(cv::Size(28, 28), CV_8UC1);
    //cvOld = cv::imread("path_to_image/digit_4.jpg", CV_8UC1); //change the directory
    //cv::Mat cvThreshold = cvOld.clone();
    //cv::adaptiveThreshold(cvOld, cvThreshold, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY_INV, 101, 1.0);
    

    //imageView_.image = [self UIImageFromCVMat:cvThreshold];
    
    
    /*
    DigitRecognizer *dr = new DigitRecognizer();
    
    
    bool b = dr->train((char*)"path_to_file/digitRecognizer/digitRecognizer/train-images.idx3-ubyte", (char*)"path_to_file/digitRecognizer/digitRecognizer/train-labels.idx1-ubyte"); //change directory
    std::cout << b << std::endl;
    
    int dist = cvThreshold.rows;
    cv::Mat cell = cv::Mat(cv::Size(dist, dist), CV_8UC1);
    for (int y = 0; y < dist; y++) {
        uchar* ptr = cell.ptr(y);
        for (int x = 0; x < dist; x++) {
            ptr[x] = cvThreshold.at<uchar>(y, x);
        }
    }
    std::cout << cvThreshold.rows << " " << cvThreshold.cols << std::endl;
    
    int number = dr->classify(cell);
    std::cout << number << std::endl;
     */
    cv::Mat input = cv::imread("/Users/xis/Desktop/digit_4.jpg", CV_8UC1);
    int number = recognize(input);
    std::cout << number << std::endl;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---------------------------------------------------------------------------------------------------------------------
// You should not have to touch these functions below to complete the assignment!!!!
//---------------------------------------------------------------------------------------------------------------------
// Quick function to draw points on an UIImage
cv::Mat DrawPts(cv::Mat &display_im, arma::fmat &pts, const cv::Scalar &pts_clr)
{
    vector<cv::Point2f> cv_pts = Arma2Points2f(pts); // Convert to vector of Point2fs
    for(int i=0; i<cv_pts.size(); i++) {
        cv::circle(display_im, cv_pts[i], 5, pts_clr,5); // Draw the points
    }
    return display_im; // Return the display image
}
// Quick function to draw lines on an UIImage
cv::Mat DrawLines(cv::Mat &display_im, arma::fmat &pts, const cv::Scalar &pts_clr)
{
    vector<cv::Point2f> cv_pts = Arma2Points2f(pts); // Convert to vector of Point2fs
    for(int i=0; i<cv_pts.size(); i++) {
        int j = i + 1; if(j == cv_pts.size()) j = 0; // Go back to first point at the enbd
        cv::line(display_im, cv_pts[i], cv_pts[j], pts_clr, 3); // Draw the line
    }
    return display_im; // Return the display image
}
// Quick function to convert Armadillo to OpenCV Points
vector<cv::Point2f> Arma2Points2f(arma::fmat &pts)
{
    vector<cv::Point2f> cv_pts;
    for(int i=0; i<pts.n_cols; i++) {
        cv_pts.push_back(cv::Point2f(pts(0,i), pts(1,i))); // Add points
    }
    return cv_pts; // Return the vector of OpenCV points
}
// Member functions for converting from cvMat to UIImage
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}
// Member functions for converting from UIImage to cvMat
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end
