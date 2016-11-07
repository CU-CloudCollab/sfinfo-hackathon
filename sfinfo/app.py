import json
import boto3
from botocore.exceptions import ClientError
from chalice import Chalice
from chalice import NotFoundError

app = Chalice(app_name='sfinfo')

app.debug = True

S3 = boto3.client('s3', region_name='us-east-1')
BUCKET = 'cu-hackathon-data'


@app.route('/')
def index():
    return {'hello': 'world'}


@app.route('/list')
def index():
    return {'idlist':[ '3001', '3002', '3003'] }


@app.route('/detail/{id}')
def get_vm_details(machine_id):
    return {'id': machine_id, 'property': 123 }


@app.route('/readFile/{key}')
def s3objects(key):
    request = app.current_request
    try:
        response = S3.get_object(Bucket=BUCKET, Key='sfinfo/sfinfo.csv')
        return response['Body'].read()
    except ClientError as e:
        raise NotFoundError(key)


# The view function above will return {"hello": "world"}
# whenver you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users/', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.json_body
#     # Suppose we had some 'db' object that we used to
#     # read/write from our database.
#     # user_id = db.create_user(user_as_json)
#     return {'user_id': user_id}
#
# See the README documentation for more examples.
#
