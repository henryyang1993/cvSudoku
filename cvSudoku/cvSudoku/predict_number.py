from __future__ import print_function, division
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

def read_digit_number(row, col):
	img_dir = 'low_resolution/gray' + str(row) + str(col) + '.jpg'
	print ("loading image: ", img_dir)
	im = cv2.imread(img_dir)
	return im

def read_test_img(i):
	img_dir = 'test' + str(i) + '.jpg'
	print ("loading image: ", img_dir)
	im = cv2.imread(img_dir)
	return im

def rotate_image(img, angle):
	#cols,rows,chs = img.shape
	#M = cv2.getRotationMatrix2D((cols/2, rows/2), angle, 1)	
	#img = cv2.warpAffine(img, M, (cols,rows))
	img = cv2.transpose(img)
	img = cv2.flip(img, 1)
	img = cv2.resize(img, (img.shape[0]*2, img.shape[1]), interpolation=cv2.INTER_AREA)
	return img

def find_bounding_box(img):

	im_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
	im_gray = cv2.GaussianBlur(im_gray, (3, 3), 0)
	ret, im_th = cv2.threshold(im_gray, 200, 255, cv2.THRESH_BINARY_INV)
	ctrs, hier = cv2.findContours(im_th.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
	rects = [cv2.boundingRect(ctr) for ctr in ctrs]
	

	print (rects)
	digit_rect = None
	for rect in rects:
		cv2.rectangle(img, (rect[0], rect[1]), (rect[0] + rect[2], rect[1] + rect[3]), (0, 255, 0), 3) 
		if (rect[2] > 20) and (rect[3] > 20):
			digit_rect = rect

	print ('digit_rect: ', digit_rect)
	return (im_th, digit_rect)

def get_roi(im_org, im_th, rect):
	cv2.rectangle(im_org, (rect[0], rect[1]), (rect[0] + rect[2], rect[1] + rect[3]), (0, 255, 0), 3) 
	
    	# Make the rectangular region around the digit
    	leng = int(rect[3] * 1.6)	
    	leng_2 = int(rect[2] * 1.6)
    	pt1 = int(rect[1] + rect[3] // 2 - leng // 2)
    	pt2 = int(rect[0] + rect[2] // 2 - leng_2 // 2)
    	if pt1 < 0:
    		pt1 = 0
    	if pt2 < 0:
    		pt2 = 0
    	
    	roi = im_th[pt1:pt1+leng, pt2:pt2+leng_2]
    	print (im_th.shape)
    	print (roi.shape)
    	# Resize the image 
    	#roi = cv2.resize(roi, (50, 100), interpolation=cv2.INTER_AREA)
    	im_th = cv2.copyMakeBorder(im_th, 20, 20, 20, 20, cv2.BORDER_CONSTANT, 0)
    	roi = cv2.resize(roi, (28, 28), interpolation=cv2.INTER_AREA)
    	roi = cv2.dilate(roi, (3, 3))
    	cv2.namedWindow("thresholded image", cv2.WINDOW_NORMAL)
	cv2.imshow("thresholded image", roi)
	cv2.waitKey()
	return roi

#def preprocess_img(im):

def predict_number(model, roi):
	digit = model.predict_classes(roi.reshape(1, 28, 28, 1), batch_size=1, verbose=1)
	print (digit)
	return digit

def recognize(img, i, model):
	#im = rotate_image(img, 270)
	roi = img
	
	#im_th, rect = find_bounding_box(im)
	#roi = get_roi(im, im_th, rect)
	#number = predict_number(model, roi)[0]
	input = roi.reshape(1, 28, 28, 1)
	print ("input shape: ", input.shape)
	input = np.float32(input)
	digit = model.predict_classes(input, batch_size=1, verbose=1)
	print ("digit: ", digit)
	return digit

def generate_board():
	model = load_model('mnist_cnn_model.h5')
	sudoku = []
	for i in range(81):
		count = 0
		test_im = read_test_img(i+1)
		test_im = cv2.cvtColor(test_im, cv2.COLOR_BGR2GRAY)
		print (test_im.shape)
		for i in range(test_im.shape[0]):
			tmp = test_im[i]
			for e in tmp:
				if e == 0:
					count += 1
		if count > 750:
			number = -1
		else:
			number = predict_number(model, test_im)[0]
		sudoku.append(number)

	sudoku = np.reshape(sudoku, (9, 9))
	print (sudoku)
	return sudoku


image_one = im = cv2.imread('test35.jpg')
image_one = cv2.cvtColor(image_one, cv2.COLOR_BGR2GRAY)
def predict_one(input):
	count = 0
	input = cv2.cvtColor(input, cv2.COLOR_BGR2GRAY)
	for i in range(input.shape[0]):
	    tmp_1 = input[i]
	    tmp_2 = image_one[i]
	    for j in range(input.shape[1]):
	        if tmp_1[j] == tmp_2[j]:
	            count += 1
	print (count)
	percent = count / (input.shape[0]*input.shape[1])
	print (percent)
	return percent

def main():
	model = load_model('mnist_cnn_model.h5')
	# img = read_digit_number(0, 0)
	# im = rotate_image(img, 270)
	# im_th, rect = find_bounding_box(im)
	
	# roi = get_roi(im, im_th, rect)
	# number = predict_number(model, roi)[0]


	# print ('number: ', number)
	sudoku = []
	for i in range(81):
		count = 0
		test_im = read_test_img(i+1)
		test_im = cv2.cvtColor(test_im, cv2.COLOR_BGR2GRAY)
		print (test_im.shape)
		for i in range(test_im.shape[0]):
			tmp = test_im[i]
			for e in tmp:
				if e == 0:
					count += 1
		if count > 750:
			number = -1
		else:
			number = predict_number(model, test_im)[0]
		sudoku.append(number)

	sudoku = np.reshape(sudoku, (9, 9))
	print (sudoku)
	# for i in xrange(9):
	# 	sub = []
	# 	for j in xrange(9):
	# 		img = read_digit_number(i, j)
	# 		#im = rotate_image(img, 270)
	# 		#im_th, rect = find_bounding_box(im)
	# 		#if rect is None:
	# 		#	number = 0
	# 		# else:
	# 		# 	roi = get_roi(im, im_th, rect)
	# 		# 	number = predict_number(model, roi)[0]
	# 		# 	print ('number: ', number)
	# 		# 	cv2.namedWindow("thresholded image", cv2.WINDOW_NORMAL)
	# 		# 	cv2.imshow("thresholded image", roi)
	# 		# 	cv2.waitKey()
	# 		sub.append(number)
	# 	sudoku.append(sub)
	# print (sudoku)
	return sudoku

if __name__ == '__main__':
  main()

img = cv2.imread("test27.jpg")
predict_one(img)

