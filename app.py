from flask import Flask, request

app = Flask(__name__)

@app.route('/example_endpoint', methods=['GET', 'POST'])
def example_endpoint():
    user_input = request.args.get('input')  # Προσομοίωση SQL Injection
    return f"Received: {user_input}"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)

