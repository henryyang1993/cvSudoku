from __future__ import print_function
import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
from keras.models import load_model
import h5py 
import cv2, cv
import numpy as np

model = load_model('mnist_cnn_model.h5')

im = cv2.imread("printed/gray41.jpg")

rows,cols,chs = im.shape
M = cv2.getRotationMatrix2D((cols/2,rows/2),270,1)
im = cv2.warpAffine(im,M,(cols,rows))


im_gray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
im_gray = cv2.GaussianBlur(im_gray, (5, 5), 0)
ret, im_th = cv2.threshold(im_gray, 90, 255, cv2.THRESH_BINARY_INV)
ctrs, hier = cv2.findContours(im_th.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
rects = [cv2.boundingRect(ctr) for ctr in ctrs]
for rect in rects:
    # Draw the rectangles
    print ("rect[2]: ", rect[2])
    print ("rect[3]: ", rect[3])
    if (abs(rect[2]-rect[3]) < 20): 
	    cv2.rectangle(im, (rect[0], rect[1]), (rect[0] + rect[2], rect[1] + rect[3]), (0, 255, 0), 3) 
	    # Make the rectangular region around the digit
	    leng = int(rect[3] * 1.6)
	    pt1 = int(rect[1] + rect[3] // 2 - leng // 2)
	    pt2 = int(rect[0] + rect[2] // 2 - leng // 2)
	    if pt1 < 0:
	    	pt1 = 0
	    if pt2 < 0:
	    	pt2 = 0
	    roi = im_th[pt1:pt1+leng, pt2:pt2+leng]
	    print (im_th.shape)
	    print (pt1)
	    print (pt1+leng)
	    print (pt2)
	    print (pt2+leng)
	    print (roi.shape)
	    # Resize the image
	    roi = cv2.resize(roi, (28, 28), interpolation=cv2.INTER_AREA)
	    roi = cv2.dilate(roi, (3, 3))

digit = model.predict_classes(roi.reshape(1, 28, 28, 1), batch_size=1, verbose=1)
print (digit)
cv2.namedWindow("Resulting Image with Rectangular ROIs", cv2.WINDOW_NORMAL)
cv2.imshow("Resulting Image with Rectangular ROIs", roi)
cv2.waitKey()


