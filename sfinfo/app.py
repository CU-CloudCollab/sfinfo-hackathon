import csv
import json
from StringIO import StringIO

import boto3
from botocore.exceptions import ClientError
from chalice import Chalice
from chalice import NotFoundError

app = Chalice(app_name='sfinfo')

app.debug = True

S3 = boto3.client('s3', region_name='us-east-1')
BUCKET = 'cu-hackathon-data'

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

table = dynamodb.Table('MachinesCollection')


@app.route('/')
def index():
    return {'hello': 'world'}


@app.route('/list')
def listvms():
    return {'idlist': []}


@app.route('/detail/{id}')
def get_vm_details(machine_id):

    try:
        response = table.get_item(
            Key={
                'id': machine_id,
                }
            )
    except ClientError as e:
        response = {'error': str(e)}

    return response
