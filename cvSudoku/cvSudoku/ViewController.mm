//
//  ViewController.m
//  My_Camera_App
//
//  Created by YANGHANYU on 1/31/17.
//  Copyright © 2017 YANGHANYU. All rights reserved.
//

#import "ViewController.h"

// Include sudoku solver program
//#include "solver.h"

// Include iostream and std namespace so we can mix C++ code in here
#include <iostream>

// Simple OpenCV Example......
#include <stdlib.h>
using namespace std;
using namespace cv;

// Define some colors here
const Scalar RED = Scalar(0,0,255);
const Scalar PINK = Scalar(230,130,255);
const Scalar PINK_BGR = Scalar(255,130,230);
const Scalar BLUE = Scalar(255,0,0);
const Scalar LIGHTBLUE = Scalar(255,255,160);
const Scalar GREEN = Scalar(0,255,0);
const Scalar WHITE = Scalar(255,255,255);

@interface ViewController ()
{
    UIImageView *liveView_; // Live output from the camera
    UIImageView *resultView_; // Preview view of everything...
    UIButton *takephotoButton_, *goliveButton_; // Button to initiate OpenCV processing of image
    CvPhotoCamera *photoCamera_; // OpenCV wrapper class to simplfy camera access through AVFoundation
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1. Setup the your OpenCV view, so it takes up the entire App screen......
    int view_width = self.view.frame.size.width;
    int view_height = (640*view_width)/480; // Work out the viw-height assuming 640x480 input
    
    liveView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, view_width, view_height)];
    [self.view addSubview:liveView_]; // Important: add liveView_ as a subview
    
    resultView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, view_width, view_height)];
    [self.view addSubview:resultView_]; // Important: add resultView_ as a subview
    resultView_.hidden = true; // Hide the view
    
    // 2. First setup a button to take a single picture
    takephotoButton_ = [self simpleButton:@"Take Photo" buttonColor:[UIColor redColor]];
    // Important part that connects the action to the member function buttonWasPressed
    [takephotoButton_ addTarget:self action:@selector(buttonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // 3. Setup another button to go back to live video
    goliveButton_ = [self simpleButton:@"Go Live" buttonColor:[UIColor greenColor]];
    // Important part that connects the action to the member function buttonWasPressed
    [goliveButton_ addTarget:self action:@selector(liveWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [goliveButton_ setHidden:true]; // Hide the button
    
    // 4. Initialize the camera parameters and start the camera (inside the App)
    photoCamera_ = [[CvPhotoCamera alloc] initWithParentView:liveView_];
    photoCamera_.delegate = self;
    
    // This chooses whether we use the front or rear facing camera
    photoCamera_.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    
    // This is used to set the image resolution
    photoCamera_.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    
    // This is used to determine the device orientation
    photoCamera_.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    // This starts the camera capture
    [photoCamera_ start];

//    UIImage *image = [UIImage imageNamed:@"sudoku.JPG"];
//    if(image != nil) liveView_.image = [self findPuzzle:image];
//    else cout << "Cannot read in the file" << endl;
    
}

-(UIImage *)findPuzzle:(UIImage *)image {
    
    cv::Mat cvImage, cvImageCopy;
    UIImageToMat(image, cvImage);
    cvImage.copyTo(cvImageCopy);
    
    cv::Mat gray;
    cv::cvtColor(cvImageCopy, gray, CV_RGBA2GRAY); // Convert to grayscale
    
//    GaussianBlur(gray, gray, cv::Size(15, 15), 1.5, 1.5);
    
    Mat thresh, threshCopy;

    // puzzle edge detect
    adaptiveThreshold(gray, thresh, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 135, 15);
    thresh.copyTo(threshCopy);
    
//    UIImage *resImage = MatToUIImage(threshCopy);
    
    // find all contours
    vector<vector<Point2i> > contours0;
    vector<Vec4i> hierarchy;
    findContours(threshCopy, contours0, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
//    cout << "contours0.size(): " << contours0.size() << endl;
    
    // get the largest one
    vector<vector<Point2i> > contours;
    contours.resize(contours0.size());

    double maxarea = 0;
    int maxi = 0;
    for (int i = 0; i < contours0.size(); i++) {
        approxPolyDP(contours0[i], contours[i], 15, true);
        if (contours[i].size() != 4)
            continue;
        if (!isContourConvex(contours[i]))
            continue;
        double area = contourArea(contours[i]);
        if (area > maxarea) {
            maxarea = area;
            maxi = i;
        }
    }

    cout << "maxi: " << endl << maxi << endl;

//    drawContours(cvImageCopy, contours, maxi, BLUE, 4, 8);
//    
//    for (int i = 0; i < contours[maxi].size(); i++) {
//        cout << contours[maxi][i] << endl;
//        circle(cvImageCopy, contours[maxi][i], 15, BLUE, 2, 8, 0);
//    }
    
    // find warp function
    vector<Point2f> corner;
    corner.push_back(contours[maxi][0]); // bottom right
    corner.push_back(contours[maxi][1]); // top right
    corner.push_back(contours[maxi][2]); // top left
    corner.push_back(contours[maxi][3]); // bottom left

    vector<Point2f> PerspectiveTransform;//透视变换后的顶点
    RotatedRect box = minAreaRect(cv::Mat(contours[maxi]));
    int w = box.boundingRect().width;
    int h = box.boundingRect().height;
    PerspectiveTransform.push_back(Point2i(w - 1, 0));
    PerspectiveTransform.push_back(Point2i(0, 0));
    PerspectiveTransform.push_back(Point2i(0, h - 1));
    PerspectiveTransform.push_back(Point2i(w - 1, h - 1));
    Mat M = getPerspectiveTransform(corner, PerspectiveTransform);//Order of points matters!
    
//    cout << "corner: " << endl << corner << endl;
//    cout << "PerspectiveTransform: " << endl << PerspectiveTransform << endl;
    
    // image transform
    cv::Size size(w, h);
    warpPerspective(cvImage, cvImageCopy, M, size);
    
    //拉普拉斯锐化
    float kernel_data[10] = {-1, -1, -1, -1, 8, -1, -1, -1, -1};
    Mat kernel(3, 3, CV_32F, kernel_data);
    cout << kernel << endl;
    filter2D(cvImageCopy, cvImageCopy, cvImageCopy.depth(), kernel);
    
    Mat warp_thresh;
    UIImage *resImage;
    
    cout << "size:" << endl;
    cout << w << " " << h << endl;
    
    cout << "matrix size:" << endl;
    cout << cvImageCopy.rows << " " << cvImageCopy.cols << endl;
    
    int rowstep = cvImageCopy.rows / 9;
    int colstep = cvImageCopy.cols / 9;
    for (int i = 0; i < 9; i += 1) {
        for (int j = 0; j < 9; j += 1) {
            Mat grid = cvImageCopy.rowRange(max(0, (int)(i * rowstep * 0.99)), min((int)((i + 1) * rowstep * 1.01), cvImageCopy.rows)).colRange(max(0, (int)(j * colstep * 0.99)), min((int)((j + 1) * colstep * 1.01), cvImageCopy.cols));
            cout << i << " " << j << endl;
            resImage = MatToUIImage([self findGrid:&grid]);
            [self saveLocal:resImage mode:@"origin" row:i col:j];
            resImage = MatToUIImage([self findGridGray:&grid]);
            [self saveLocal:resImage mode:@"gray" row:i col:j];
            resImage = MatToUIImage([self findGridEdge:&grid]);
            [self saveLocal:resImage mode:@"edge" row:i col:j];
        }
    }
    
    resImage = MatToUIImage(cvImageCopy);

    // Special part to ensure the image is rotated properly when the image is converted back
    UIImage *retImage = [UIImage imageWithCGImage:[resImage CGImage] scale:1.0 orientation:UIImageOrientationRight];
    
    return retImage;
}

-(Mat)findGrid:(Mat *)grid {
    cv::Mat gridCopy;
    (*grid).copyTo(gridCopy);
    
    return gridCopy;
}

-(Mat)findGridGray:(Mat *)grid {
    cv::Mat gridCopy;
    (*grid).copyTo(gridCopy);
    
    Mat warp_gray;
    cv::cvtColor(gridCopy, warp_gray, CV_RGBA2GRAY); // Convert to grayscale
    
    return warp_gray;
}


-(Mat)findGridEdge:(Mat *)grid {
    cv::Mat gridCopy;
    (*grid).copyTo(gridCopy);
    
    Mat warp_gray;
    cv::cvtColor(gridCopy, warp_gray, CV_RGBA2GRAY); // Convert to grayscale
    
//    GaussianBlur(warp_gray, warp_gray, cv::Size(15, 15), 1.5, 1.5);
    
    Mat thresh, threshCopy;
    
    // grid edge detect
    adaptiveThreshold(warp_gray, thresh, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 135, 15);
    thresh.copyTo(threshCopy);
    
    return threshCopy;
}

-(void)saveLocal:(UIImage *)pic mode:(NSString* )m row:(int)i col:(int)j {
    // Special part to ensure the image is rotated properly when the image is converted back
    UIImage *retImage = [UIImage imageWithCGImage:[pic CGImage] scale:1.0 orientation:UIImageOrientationRight];
    
    // Create paths to output images
    NSString *filename = [NSString stringWithFormat:@"Documents/%@%d%d.jpg", m, i, j];
    NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
//    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
    
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
    [UIImageJPEGRepresentation(retImage, 1.0) writeToFile:jpgPath atomically:YES];
    NSLog(@"%@", jpgPath);
    
    // Write image to PNG
//    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}


//===============================================================================================
// This member function is executed when the button is pressed
- (void)buttonWasPressed {
    [photoCamera_ takePicture];
}
//===============================================================================================
// This member function is executed when the button is pressed
- (void)liveWasPressed {
    [takephotoButton_ setHidden:false]; [goliveButton_ setHidden:true]; // Switch visibility of buttons
    resultView_.hidden = true; // Hide the result view again
    [photoCamera_ start];
}
//===============================================================================================
// To be compliant with the CvPhotoCameraDelegate we need to implement these two methods
- (void)photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)image
{
    [photoCamera_ stop];
    resultView_.hidden = false; // Turn the hidden view on
    
    resultView_.image = [self findPuzzle:image];
    
    [takephotoButton_ setHidden:true]; [goliveButton_ setHidden:false]; // Switch visibility of buttons
}

- (void)photoCameraCancel:(CvPhotoCamera *)photoCamera
{
    
}

//===============================================================================================
// Simple member function to initialize buttons in the bottom of the screen so we do not have to
// bother with storyboard, and can go straight into vision on mobiles
//
- (UIButton *) simpleButton:(NSString *)buttonName buttonColor:(UIColor *)color
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; // Initialize the button
    // Bit of a hack, but just positions the button at the bottom of the screen
    int button_width = 200; int button_height = 50; // Set the button height and width (heuristic)
    // Botton position is adaptive as this could run on a different device (iPAD, iPhone, etc.)
    int button_x = (self.view.frame.size.width - button_width)/2; // Position of top-left of button
    int button_y = self.view.frame.size.height - 80; // Position of top-left of button
    button.frame = CGRectMake(button_x, button_y, button_width, button_height); // Position the button
    [button setTitle:buttonName forState:UIControlStateNormal]; // Set the title for the button
    [button setTitleColor:color forState:UIControlStateNormal]; // Set the color for the title
    
    [self.view addSubview:button]; // Important: add the button as a subview
    //[button setEnabled:bflag]; [button setHidden:(!bflag)]; // Set visibility of the button
    return button; // Return the button pointer
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end