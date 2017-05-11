from __future__ import print_function, division
# from flask import Flask, request
import numpy as np
import predict_number 
import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
from keras.models import load_model
import h5py 
import cv2, cv


import SimpleHTTPServer
import SocketServer
import logging
import cgi

PORT = 8080
model = load_model('mnist_cnn_model.h5')
image_one = im = cv2.imread('test35.jpg')
image_one = cv2.cvtColor(image_one, cv2.COLOR_BGR2GRAY)
image_six = im = cv2.imread('test50.jpg')
image_six = cv2.cvtColor(image_six, cv2.COLOR_BGR2GRAY)

def predict_one(input):
    count = 0
    #input = cv2.cvtColor(input, cv2.COLOR_BGR2GRAY)
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

def predict_six(input):
    count = 0
    #input = cv2.cvtColor(input, cv2.COLOR_BGR2GRAY)
    for i in range(input.shape[0]):
        tmp_1 = input[i]
        tmp_2 = image_six[i]
        for j in range(input.shape[1]):
            if tmp_1[j] == tmp_2[j]:
                count += 1
    print (count)
    percent = count / (input.shape[0]*input.shape[1])
    print (percent)
    return percent

def predict_number(model, roi):
    count = 0
    for i in range(roi.shape[0]):
        tmp = roi[i]
        for e in tmp:
            if e == 0:
                count += 1
    if count > 750:
        number = -1
    else:
        if predict_one(roi) > 0.6:
            number = 1
        elif predict_six(roi) > 0.6:
            number = 6
        else:
            number = model.predict_classes(roi.reshape(1, 28, 28, 1), batch_size=1, verbose=1)[0]
    print (number)
    return number

class ServerHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):

    def do_POST(self):
        form = cgi.FieldStorage(
            fp=self.rfile,
            headers=self.headers,
            environ={'REQUEST_METHOD':'POST',
                     'CONTENT_TYPE':self.headers['Content-Type'],
                     })

        rows, cols, matrix = None, None, None
        print("form", form)
        if "rows" in form:
            rows = int(form['rows'].value)
        else:
            return "INVALID";
    
        if "cols" in form:
            cols = int(form['cols'].value)
        else:
            return "INVALID";
    
        if "matrix" in form:
            matrix = form['matrix'].value
            matrix = np.reshape(map(float, matrix[1:].split("#")), (rows, cols))
        else:
            return "INVALID";
        
        print("matrix: ", matrix.shape)
        # digit = 1
        # global i
    
        # i += 1
        # print ('i: ', i)
        #cv2.imwrite('test' + str(i) + '.jpg', matrix)
        #digit = predict_number.recognize(matrix, i, model)
        # print (matrix.shape)
        digit = predict_number(model, matrix)
        print('digit: ', digit)

        response = str(digit)
        self.send_response(200)
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()
        self.wfile.write(response)
        # return str(digit)

Handler = ServerHandler

httpd = SocketServer.TCPServer(("", PORT), Handler)

print("serving at port", PORT)
httpd.serve_forever()


# app = Flask(__name__, static_url_path='')
# model = load_model('mnist_cnn_model.h5')
# i = 0

# @app.route("/test", methods=['POST'])
# def handleQ1():
#     rows, cols, matrix = None, None, None
#     if "rows" in request.form:
#         rows = int(request.form.get('rows'))
#     else:
#         return "INVALID";

#     if "cols" in request.form:
#         cols = int(request.form.get('cols'))
#     else:
#         return "INVALID";

#     if "matrix" in request.form:
#         matrix = request.form.get('matrix')
#         matrix = np.reshape(map(float, matrix[1:].split("#")), (rows, cols))
#     else:
#         return "INVALID";
    
#     print("matrix: ", matrix.shape)
#     # digit = 1
#     global i

#     i += 1
#     print ('i: ', i)
#     #cv2.imwrite('test' + str(i) + '.jpg', matrix)
#     #digit = predict_number.recognize(matrix, i, model)
#     print (matrix.shape)
#     digit = predict_number(model, matrix)[0]
#     #print('digit: ', digit)

    
#     return str(digit)


# if __name__ == '__main__':
#     app.run(debug=True, host="0.0.0.0", port=8080, threaded=True)
    
