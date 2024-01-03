import json
import pandas as pd
from prophet import Prophet


def convert_to_dataframe(forecast_request):
    data = {
        'ds': [],
        'y': [],
    }

    for timeseries in forecast_request:
        data['ds'].append(timeseries.get('timestamp'))
        data['y'].append(timeseries.get('data'))

    df = pd.DataFrame(data)
    df['ds'] = pd.to_datetime(df['ds'], unit='s')
    df = df.dropna(axis=1, how='all')
    return df


def lambda_handler(event, context):
    forecast_request = json.loads(event['body'])
    df = convert_to_dataframe(forecast_request)

    model = Prophet()
    model.fit(df)
    future = model.make_future_dataframe(periods=48, freq='H')
    predictions = model.predict(future)

    response = []
    for i, row in predictions.iterrows():
        forecast = dict()
        forecast['timestamp'] = int(row['ds'].timestamp())
        forecast['prediction'] = round(row['yhat'])
        response.append(forecast)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "http://localhost:3000",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept, Authorization",
        },
        "body": json.dumps(response)
    }

# if __name__ == '__main__':
#     with open('data.json') as f:
#         data = json.load(f)
#     event = {'body': json.dumps(data)}
#     print(lambda_handler(event, None))