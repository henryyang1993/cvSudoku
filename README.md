# 16423 Final Project Checkpoint 
Team Member: Hanyu Yang (hanyuy), Xi Sun (xis)

### Title
cvSudoku ([YouTube Playlist](https://www.youtube.com/playlist?list=PL6UuR-LmCZb6zDEEhoDGfS-63D7cWFCzI))

### Summary

In this project we are developing an iOS application that allows users to interact with a printed Sudoku on their iOS devices. This project involves computer vision and machine learning techniques such as edge detection, contour finding, warp transform, digit recognition and deep learning.

### Task completed

* Sudoku puzzle board (hanyuy)
	
	On top of the photo taking project in previous assignment, I develop employ OpenCV libraries to detect all edges in the photo, find the largest contour, which is the sudoku puzzle.

* Warp Transform and digit grid extraction (hanyuy)
	
	After finding the largest contour, we can train the warp transform parameters based on the corners of the contour, and then apply the transform to the whole sudoku board to display on full screen. Then averagely divide into 9 * 9 grids.

* Digit recognition (xis) 

	Able to train and classify pictures of hand-written or printed numbers. Trains the parameters using the K-Nearest Neighbors in OpenCV. The testing data is read in from images including a single number, either handwritten or printed. The inputs are stored as 28x28 images, and the labels are simply a number between 0 and 9.
	
* Preprocessing the input images
	
	The input images are preprocessed so that the number (main content) in the image is centered and thresholded, and is of the same format as the training images. 

### Task to do

* Sudoku Solver (hanyuy)

	For the first week, we will combine our functions together and try to construct a sudoku matrix and solve it.

* Digits distinguish (xis)

	For the second week, we will try to distinguish the printed digit (puzzle) from handwritten ones (half completed one).
	
* Screen Interaction (together)

	For the third week, we will detect screen touch operation on grids and display possible digit options for users.

* Improve performance and exploration (together)

	Finally, we will find out the bottleneck of the App and try to substitute with better solution and explore advanced features.

### Questions

* What is the best way to commit for an xcode project? Are we supposed to upload configuration files, frameworks and libraries to Github or just source code? 

* What is the most efficient way to extract contents from camera frames and provide feedback to users based on interaction?

### Reference:
* [Sudoku recognizer](http://www.shogun-toolbox.org/static/notebook/current/Sudoku_recognizer.html#Sudoku-recognizer)

