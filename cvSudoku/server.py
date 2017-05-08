from flask import Flask, request
import numpy as np


app = Flask(__name__, static_url_path='')

@app.route("/test", methods=['POST'])
def handleQ1():
    rows, cols, matrix = None, None, None
    if "rows" in request.form:
        rows = int(request.form.get('rows'))
    else:
        return "INVALID";

    if "cols" in request.form:
        cols = int(request.form.get('cols'))
    else:
        return "INVALID";

    if "matrix" in request.form:
        matrix = request.form.get('matrix')
        matrix = np.reshape(map(int, matrix[1:].split("#")), (rows, cols))
    else:
        return "INVALID";
    
    print(matrix)
    digit = 1
    # digit = recognize(matrix)
    
    return str(digit)


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8080, threaded=True)
    
