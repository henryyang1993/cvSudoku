# 16423 Final Project Proposal 

### Title
cvSudoku

### Summary
In this project we are developing an iOS application that allows users to solve printed Sudoku. The application automatically generates the solution or prints “Invalid Board” after the device camera captures the board. Once the user clicks on one of the blank spaces, a list of valid digit options pops up for the user to enter, either through voice input or by clicking on the options. The entered digit appears on the screen as augmented reality. Once the board is filled, the application gives feedback on correctness based on the solution generated. 

This project involves computer vision techniques such as Hough transform for detecting the frame, and digit recognition. 

### Background
To detect the frame and project numbers, we will need feature point detectors, descriptor generators, as well as homography and camera extrinsic matrices computation.

* We would use SIFT, FAST or BRIEF to detect feature points and generate descriptors. 
* To speed up matrix computation, we would use the Armadillo Library. 
* LK algorithm or Correlation filters would be applied to keep track of the movement of the Sudoku board in real-time.
* Learning algorithms and MNIST dataset might be applied for handwritten digits recognition.
* Algorithm to solve Sudoku puzzles.

### Challenges
In this project, the following problems need to be solved:

* Detect Sudoku grids and digits. Since we need to recognize both printed and handwriting version of digits, it takes time.
* Solve the Sudoku for correctness checking. It should have open-source algorithms for our reference.
* Real-time tracking of the Sudoku board. Not easy to do it efficiently.
* Touch selection and voice input. Since camera takes up the screen, touch and voice interactions seem more user-friendly.
* AR display of the digits. If we have time, we will explore to use AR techniques in the project.

### Goals & Deliverables
Our basic goal is to develop an iOS App that can recognize an unsolved Sudoku and let you complete it with touch select grid and voice input interaction. If it goes really well and we get ahead of schedule, we will consider to add AR techniques on digit options display.

Finally we will deliver our achievements through a YouTube video and show how to run it on in-class presentation if possible. I believe we could finish at least the basic goal of our project.

### Schedule
We have approximately 4 weeks to complete the project, with a checkpoint due in 2 weeks. So we schedule the development process roughly as follow:

* Week 1: Build an iOS app to detect grids and digits of a Sudoku (static).
* Week 2: Complete Sudoku algorithm and implement correctness checking. (Check Point)
* Week 3: Real-time tracking, grid select by screen touch and Voice input. 
* Week 4: Improve performance and explore AR techniques (optional).

### Reference:
* [IPHONE SUDOKU GRAB](http://sudokugrab.blogspot.com/2009/07/how-does-it-all-work.html)
* [SuDoKu Grabber in OpenCV](http://aishack.in/tutorials/sudoku-grabber-opencv-plot/)
* [Vuforia Developer Portal](https://developer.vuforia.com/)



