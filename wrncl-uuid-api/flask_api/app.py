import os
import uuid

import boto3
from boto3.dynamodb.conditions import Key, Attr

from flask import request, jsonify
from flask_lambda import FlaskLambda

EXEC_ENV = os.environ['EXEC_ENV']
REGION = os.environ['REGION_NAME']
TABLE_NAME = os.environ['TABLE_NAME']

app = FlaskLambda(__name__)

dynamodb = boto3.resource('dynamodb', region_name=REGION)


def db_table(table_name=TABLE_NAME):
    print(f'Getting dynamodb table {table_name}')
    return dynamodb.Table(table_name)


@app.route('/job/name/<string:job_name>', methods=('POST',))
def create_job(job_name):
    print(f'Creating UUID for job_name: {job_name}')
    job_id = str(uuid.uuid4())

    print(f'Getting table')
    tbl = db_table()
    print(f'putting item in table')
    tbl.put_item(Item={'jobId': job_id, 'jobName': job_name})
    print(f'Checking if item is in table')
    tbl_response = tbl.get_item(Key={'jobName': job_name})

    print(f'Checking if item is in table2')
    created_item = jsonify(tbl_response['Item'])
    print(f'Inserted Item: {created_item}')
    return created_item, 200


@app.route('/job/name/<string:job_name>')
def fetch_job_uuid(job_name):
    response = db_table().query(
        KeyConditionExpression=Key('jobName').eq(job_name)
    )

    print(f'Response from query: {response}')

    return jsonify(response['Items'][0]['jobId'])


@app.route('/job/uuid/<string:job_id>')
def fetch_job_name(job_id):
    response = db_table().scan(
        FilterExpression=Attr('jobId').eq(job_id)
    )

    print(f'Response from query: {response}')

    return jsonify(response['Items'][0]['jobName'])
