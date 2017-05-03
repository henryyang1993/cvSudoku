from flask import Flask, request
from datetime import datetime


app = Flask(__name__, static_url_path='')

@app.route("/test", methods=['GET'])
def handleQ1():
    if "matrix" in request.args:
        matrix = request.args.get('matrix')
    else:
        return "INVALID";
    
    print(matrix)
    digit = 1
    # digit = recognize(matrix)
    
    return str(digit)


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8080, threaded=True)
    
