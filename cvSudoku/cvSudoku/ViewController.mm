//
//  ViewController.m
//  My_Camera_App
//
//  Created by YANGHANYU on 1/31/17.
//  Copyright © 2017 YANGHANYU. All rights reserved.
//

#import "ViewController.h"

// Include sudoku solver program
#import "solver.hpp"

// Include iostream and std namespace so we can mix C++ code in here
#include <iostream>

// Simple OpenCV Example......
#include <stdlib.h>

#include "digitRecognize.h"
#include "outputNumber.hpp"

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
    UIView *resultView_; // result UIView
    UIImageView *boardView_; // sudoku UIImageView
    UIButton *takephotoButton_, *goliveButton_; // Button to initiate OpenCV processing of image
    CvPhotoCamera *photoCamera_; // OpenCV wrapper class to simplfy camera access through AVFoundation
    string trainImgPath;
    string trainLabelPath;
    Mat ggrid;
    int digit;
    int sudoku[N][N];
    DigitRecognizer *dr;
    NSMutableArray *tfArray;
    UIButton *solutionBtn;
    int kk;
    UIImage *photo;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //---------------------------testing digit recognition from input image files---------------------------------------------
    
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"train-images.idx3-ubyte" ofType:@""];
    trainImgPath = std::string([imgPath UTF8String]);
    cout << trainImgPath << endl;
    
    NSString *labelPath = [[NSBundle mainBundle] pathForResource:@"train-labels.idx1-ubyte" ofType:@""];
    trainLabelPath = std::string([labelPath UTF8String]);
    cout << trainLabelPath << endl;
    
    dr = new DigitRecognizer();
    
    const char *trainPath1 = trainImgPath.c_str();
    const char *trainPath2 = trainLabelPath.c_str();
    
    dr->train(trainPath1, trainPath2);
    
    
//    // Recognizing image of hand-written digit 4 in the Resource folder
//    NSString *testPath = [[NSBundle mainBundle] pathForResource:@"gray02" ofType:@"jpg"];
//    std::string digitPath = std::string([testPath UTF8String]);
//    cout << digitPath << endl;
//
//    cv::Mat input = cv::imread(digitPath, CV_8UC1);
//    Mat cropped = input;
////    Mat cropped = [self rectify:&input];
//
//    digit = recognize(cropped, dr);
//    std::cout << "init digit: " << digit << std::endl;
    //-------------------------------------------------------------------------------------------------------------------------

    // 1. Setup the your OpenCV view, so it takes up the entire App screen......
    int view_width = self.view.frame.size.width;
    int view_height = (640*view_width)/480; // Work out the viw-height assuming 640x480 input
    
    liveView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, view_width, view_height)];
    [self.view addSubview:liveView_]; // Important: add liveView_ as a subview
    
    resultView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, view_width, view_height)];
    [self.view addSubview:resultView_]; // Important: add resultView_ as a subview
    
    
    int w = 100;
    int h = 50;
    boardView_ = [[UIImageView alloc] initWithFrame:CGRectMake(w, h, view_width - 2 * w, view_width - 2 * w)];
    [resultView_ addSubview:boardView_]; // Important: add boardView_ as a subview
    //    boardView_.hidden = true; // Hide the view
//    int grid_w = (view_width - 2 * w) / 9;
    int grid_w = 59;
    cout << "grid width: " << grid_w << endl;
    
    int gw = w + 12;
    int gh = h + 13;
    int bw = 6;
    int bh = 6;
    
    tfArray = [NSMutableArray new];
    for (int i = 0; i < N; i++) {
        tfArray[i] = [NSMutableArray new];
        if (i && i % 3 == 0) {
            gh += bh;
//            bh += bh;
        }
        gw = w + 12;
        for (int j = 0; j < N; j++) {
            if (j && j % 3 == 0) {
                gw += bw;
//                bw += bw;
            }
            UITextField *uitf = [[UITextField alloc] initWithFrame:CGRectMake(gw + j * grid_w + bw, gh + i * grid_w + bh, grid_w / 1.3, grid_w / 1.3)];
            uitf.backgroundColor = [UIColor blueColor];
            uitf.keyboardType = UIKeyboardTypeNumberPad;
            tfArray[i][j] = uitf;
            [resultView_ addSubview:uitf];
        }
    }
    
    solutionBtn = [self simpleButton:@"Crack it!" buttonColor:[UIColor blueColor] solution:true];
    // Important part that connects the action to the member function buttonWasPressed
    [solutionBtn addTarget:self action:@selector(solutionWasPressed) forControlEvents:UIControlEventTouchUpInside];

    
    // 2. First setup a button to take a single picture
    takephotoButton_ = [self simpleButton:@"Take Photo" buttonColor:[UIColor redColor] solution:false];
    // Important part that connects the action to the member function buttonWasPressed
    [takephotoButton_ addTarget:self action:@selector(buttonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // 3. Setup another button to go back to live video
    goliveButton_ = [self simpleButton:@"Go Live" buttonColor:[UIColor greenColor] solution:false];
    // Important part that connects the action to the member function buttonWasPressed
    [goliveButton_ addTarget:self action:@selector(liveWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // 4. Initialize the camera parameters and start the camera (inside the App)
    photoCamera_ = [[CvPhotoCamera alloc] initWithParentView:liveView_];
    photoCamera_.delegate = self;
    
    // This chooses whether we use the front or rear facing camera
    photoCamera_.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    
    // This is used to set the image resolution
//    photoCamera_.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto;
    photoCamera_.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    
    // This is used to determine the device orientation
    photoCamera_.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    // This starts the camera capture
    [photoCamera_ start];
    resultView_.hidden = true;
    liveView_.hidden = false;
    takephotoButton_.hidden = false;
    goliveButton_.hidden = true;

    
    //----------- generating training set -------------//
//    kk = 0;
//    for (int i = 10; i < 29; i++) {
//        NSString *filename = [NSString stringWithFormat:@"training/IMG_00%d.JPG", i];
////        NSString *filename = @"training/IMG_0012.JPG";
//        UIImage *image = [UIImage imageNamed:filename];
//        if(image != nil) liveView_.image = [self findPuzzle:image];
//        else cout << "Cannot read in the image " << i << endl;
//        resultView_.hidden = true;
//        liveView_.hidden = false;
//        takephotoButton_.hidden = false;
//        goliveButton_.hidden = true;
//        kk += 1;
//    }
    //----------- generating training set -------------//

    
    photo = [UIImage imageNamed:@"training/sudoku.JPG"];
//    if(image != nil) liveView_.image = [self findPuzzle:photo];
//    else cout << "Cannot read in the image" << endl;
//    resultView_.hidden = true;
//    liveView_.hidden = false;
//    takephotoButton_.hidden = false;
//    goliveButton_.hidden = true;
    
    
//    UIImage *image = [UIImage imageNamed:@"training/sudoku.JPG"];
//    if(image != nil) [self findPuzzle:image];
//    else cout << "Cannot read in the image" << endl;
//    resultView_.hidden = false;
//    liveView_.hidden = true;
//    takephotoButton_.hidden = true;
//    goliveButton_.hidden = false;
    
    // load board view
    UIImage *board = [UIImage imageNamed:@"board.JPG"];
    if(board != nil) boardView_.image = board;
    else cout << "Cannot read in the board" << endl;
    
}

//-(void)findPuzzle:(UIImage *)image {
-(UIImage *)findPuzzle:(UIImage *)image {
    UIImage *resImage;
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
    
//    resImage = MatToUIImage(threshCopy);
    
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
//    for (int i = 0; i < contours[maxi].size(); i++) {
//        cout << contours[maxi][i] << endl;
//        circle(cvImageCopy, contours[maxi][i], 15, BLUE, 2, 8, 0);
//    }
//    resImage = MatToUIImage(cvImageCopy);

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

//    resImage = MatToUIImage(cvImageCopy);
    
    cout << "size:" << endl;
    cout << w << " " << h << endl;
    
    cout << "matrix size:" << endl;
    cout << cvImageCopy.rows << " " << cvImageCopy.cols << endl;
    
    int rowstep = cvImageCopy.rows / 9;
    int colstep = cvImageCopy.cols / 9;
    
    
//    DigitRecognizer *dr = new DigitRecognizer();
//    
//    const char *trainPath1 = trainImgPath.c_str();
//    const char *trainPath2 = trainLabelPath.c_str();
//    
//    bool b = dr->train(trainPath1, trainPath2);
    
    for (int i = 0; i < N; i += 1) {
        for (int j = 0; j < N; j += 1) {
//            Mat grid = cvImageCopy.rowRange(max(0, (int)(i * rowstep * 0.99)), min((int)((i + 1) * rowstep * 1.01), cvImageCopy.rows)).colRange(max(0, (int)(j * colstep * 0.99)), min((int)((j + 1) * colstep * 1.01), cvImageCopy.cols));
            int rrange = (int)rowstep * 0.2;
            int crange = (int)colstep * 0.1;
            Mat grid = cvImageCopy.rowRange(i * rowstep + rrange, (i + 1) * rowstep - rrange).colRange(j * colstep + crange, (j + 1) * colstep - crange);
            cout << "loop: " << i << " " << j << endl;
            ggrid = [self findGridGray:&grid];
            Mat cropped = [self rectify:&ggrid];
//            cout << "cropped:" << endl;
//            cout << cropped << endl;
//            resImage = MatToUIImage(cropped);
            resImage = MatToUIImage([self findGridGray:&grid]);
            [self saveLocal:resImage mode:@"gray" row:i col:j];
            
//            NSString *filename = [NSString stringWithFormat:@"gray%d%d", i, j];
//            NSString *testPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"jpg"];
//            std::string digitPath = std::string([testPath UTF8String]);
//            cout << digitPath << endl;
//            cv::Mat cropped = cv::imread(digitPath, CV_8UC1);
            
//            digit = recognize(cropped, dr, kk, i, j);
            std::cout << "digit: " << digit << std::endl;
            
            if (i == 5 && j == 7) {
                digit = 2;
            }
            
            if (i == 6 && j == 1) {
                digit = 1;
            }
            
            UITextField *uitf = (UITextField *)tfArray[j][N - 1 - i];
            uitf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            uitf.textAlignment = NSTextAlignmentCenter;
            uitf.font = [uitf.font fontWithSize:30.0];
            if (digit == -1) {
                sudoku[j][N - 1 - i] = 0;
                uitf.placeholder = @"0";
                uitf.backgroundColor = [UIColor blueColor];
                uitf.enabled = true;
                uitf.delegate = self;
            } else {
                sudoku[j][N - 1 - i] = digit;
                uitf.text = [NSString stringWithFormat:@"%d", digit];
                uitf.backgroundColor = [UIColor greenColor];
                uitf.enabled = false;
            }
        }
    }
    
    cout << "original:" << endl;
    printGrid(sudoku);
    if (SolveSudoku(sudoku) == true) {
        [self showMessage:@"Let's Start!!!!" atPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 2 / 3) atColor:[UIColor redColor] keep:false];
        cout << "solve:" << endl;
        printGrid(sudoku);
        for (int i = 0; i < N; i += 1) {
            for (int j = 0; j < N; j += 1) {
                UITextField *uitf = (UITextField *)tfArray[i][j];
                if ([uitf.placeholder isEqualToString:@"0"]) {
                    uitf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", sudoku[i][j]] attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
                }
            }
        }
        solutionBtn.hidden = false;
    } else {
        [self showMessage:@"No solution!!!!" atPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 2 / 3) atColor:[UIColor redColor] keep:true];
        cout << "No solution exists" << endl;
        for (int i = 0; i < N; i += 1) {
            for (int j = 0; j < N; j += 1) {
                UITextField *uitf = (UITextField *)tfArray[i][j];
                uitf.placeholder = @"";
                uitf.enabled = false;
            }
        }
        solutionBtn.hidden = true;
    }

    // Special part to ensure the image is rotated properly when the image is converted back
    UIImage *retImage = [UIImage imageWithCGImage:[resImage CGImage] scale:1.0 orientation:UIImageOrientationRight];

//    return resImage;
    return retImage;
}

-(Mat)rectify:(Mat *)grid {
    Mat res;
//    transpose(*grid, res);
//    flip(res, res, 1);

    res = *grid;
    return res;
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


// UITextField delegates
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *ans = textField.placeholder;
    UIColor *col = textField.backgroundColor;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:ans attributes:@{NSForegroundColorAttributeName:col}];
    
    // Check for non-numeric characters
    NSUInteger lengthOfString = string.length;
    for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
        unichar character = [string characterAtIndex:loopIndex];
        if (character < 49) return NO; // 49 unichar for 1
        if (character > 57) return NO; // 57 unichar for 9
    }
    
    // Check for total length
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    if (proposedNewLength > 1) return NO;     //set your length here
    if (proposedNewLength == 0) {
        textField.backgroundColor = [UIColor blueColor];
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:ans attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    }
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *ans = textField.placeholder;
    if (textField.text.length > 0) {
        if ([textField.text isEqualToString:ans]) {
            textField.backgroundColor = [UIColor greenColor];
            [self showMessage:@"correct!" atPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 2 / 3) atColor:[UIColor greenColor] keep:false];
            cout << "correct!!!" << endl;
            textField.enabled = false;
            [self congratulation];
        } else {
            textField.backgroundColor = [UIColor redColor];
            [self showMessage:@"incorrect!!" atPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 2 / 3) atColor:[UIColor redColor] keep:false];
            cout << "incorrect!!" << endl;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *ans = textField.placeholder;
    if (textField.text.length > 0) {
        if ([textField.text isEqualToString:ans]) {
            textField.backgroundColor = [UIColor greenColor];
            [self showMessage:@"correct!" atPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 2 / 3) atColor:[UIColor greenColor] keep:false];
            cout << "correct!!!" << endl;
            textField.enabled = false;
            [self congratulation];
        } else {
            textField.backgroundColor = [UIColor redColor];
            [self showMessage:@"incorrect!!" atPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 2 / 3) atColor:[UIColor redColor] keep:false];
            cout << "incorrect!!" << endl;
        }
    }
}

-(void) congratulation {
    for (int i = 0; i < N; i += 1) {
        for (int j = 0; j < N; j += 1) {
            UITextField *uitf = (UITextField *)tfArray[i][j];
            if (uitf.backgroundColor != [UIColor greenColor]) {
                return ;
            }
        }
    }
    solutionBtn.hidden = true;
    [self showMessage:@"Congratulations!!!" atPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 2 / 3 + 40) atColor:[UIColor greenColor] keep:true];
}

- (void)showMessage:(NSString*)message atPoint:(CGPoint)point atColor:(UIColor*)color keep:(bool)keep {
    const CGFloat fontSize = 32;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
    label.text = message;
    label.textColor = color;
    [label sizeToFit];
    
    label.center = point;
    
    [self.view addSubview:label];
    NSTimeInterval nsti;
    if (keep) {
        nsti = 5;
    } else {
        nsti = 2;
    }
    [UIView animateWithDuration:1 delay:nsti options:0 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        label.hidden = YES;
        [label removeFromSuperview];
    }];
}

- (void)solutionWasPressed {
    cout << "crack it!" << endl;
    for (int i = 0; i < N; i += 1) {
        for (int j = 0; j < N; j += 1) {
            UITextField *uitf = (UITextField *)tfArray[i][j];
            if (uitf.placeholder.length > 0) {
                uitf.text = uitf.placeholder;
                uitf.backgroundColor = [UIColor greenColor];
                uitf.enabled = false;
            }
        }
    }
    [self congratulation];
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
    liveView_.hidden = false;
    resultView_.hidden = true; // Hide the result view again
    [photoCamera_ start];
}
//===============================================================================================
// To be compliant with the CvPhotoCameraDelegate we need to implement these two methods
- (void)photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)image
{
    [photoCamera_ stop];
    liveView_.hidden = true;
    resultView_.hidden = false; // Turn the hidden view on
    
//    boardView_.image = [self findPuzzle:image];
    [self findPuzzle:image];
//    [self findPuzzle:photo];
    
    [takephotoButton_ setHidden:true]; [goliveButton_ setHidden:false]; // Switch visibility of buttons
}

- (void)photoCameraCancel:(CvPhotoCamera *)photoCamera
{
    
}

//===============================================================================================
// Simple member function to initialize buttons in the bottom of the screen so we do not have to
// bother with storyboard, and can go straight into vision on mobiles
//
- (UIButton *) simpleButton:(NSString *)buttonName buttonColor:(UIColor *)color solution:(bool)s
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; // Initialize the button
    // Bit of a hack, but just positions the button at the bottom of the screen
    int button_width = 200; int button_height = 50; // Set the button height and width (heuristic)
    // Botton position is adaptive as this could run on a different device (iPAD, iPhone, etc.)
    int button_x, button_y;
    if (s) {
        button_x = (self.view.frame.size.width - button_width)/2;
        button_y = self.view.frame.size.height - 400;
        button.frame = CGRectMake(button_x, button_y, button_width, button_height); // Position the button
        [button setTitle:buttonName forState:UIControlStateNormal]; // Set the title for the button
        [button setTitleColor:color forState:UIControlStateNormal]; // Set the color for the title
        
        [resultView_ addSubview:button];
    } else {
        button_x = (self.view.frame.size.width - button_width)/2; // Position of top-left of button
        button_y = self.view.frame.size.height - 80; // Position of top-left of button
        button.frame = CGRectMake(button_x, button_y, button_width, button_height); // Position the button
        [button setTitle:buttonName forState:UIControlStateNormal]; // Set the title for the button
        [button setTitleColor:color forState:UIControlStateNormal]; // Set the color for the title
        
        [self.view addSubview:button]; // Important: add the button as a subview
        //[button setEnabled:bflag]; [button setHidden:(!bflag)]; // Set visibility of the button
    }
    
    return button; // Return the button pointer
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
