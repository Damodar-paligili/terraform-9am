
import json
import boto3
import pymysql
import os

client = boto3.client("secretsmanager")

SECRET_NAME = os.getenv("SECRET_NAME")
RDS_HOST = os.getenv("RDS_HOST")

def lambda_handler(event, context):

    response = client.get_secret_value(SecretId=SECRET_NAME)
    secret = json.loads(response["SecretString"])

    connection = pymysql.connect(
        host=RDS_HOST,
        user=secret["username"],
        password=secret["password"],
        port=3306
    )

    cursor = connection.cursor()
    cursor.execute("SELECT VERSION();")
    result = cursor.fetchone()

    connection.close()

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Connected Successfully",
            "mysql_version": result[0]
        })
    }