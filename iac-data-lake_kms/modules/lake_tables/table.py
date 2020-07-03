import boto3
import sys
import json

def get_table_schema(zone_name):
    with open("../tabledata/" + zone_name + '.json') as json_file:
        data = json.load(json_file)
        return data['tab_cols'] ,data['tab_param'] ,data['tab_description']

def create_table(database_name,data_location,table_domain,table_zone,tab_cols ,tab_param ,tab_description):
    client = boto3.client('glue')    
    response = client.create_table(DatabaseName=database_name,
                                   TableInput={
        'Name': 'lake_' + table_domain + '_' + table_zone + '_stage',
        'Description': tab_description,
        'StorageDescriptor': {
            'Columns': tab_cols,
            'Location': 's3://' + data_location + '/stage/',
            'InputFormat': 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat',
            'OutputFormat': 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat',
            'NumberOfBuckets': 0,
            'SerdeInfo': {'SerializationLibrary': 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
                          , 'Parameters': {'serialization.format': '1'
                          }},
            'SortColumns': [],
            },
        'PartitionKeys': [],
        'TableType': 'EXTERNAL_TABLE',
        'Parameters': tab_param,
        })


if __name__ == '__main__':    
    database_name = sys.argv[1]
    data_location = sys.argv[2]
    table_domain  = sys.argv[3]
    table_zone    = sys.argv[4]    
    print("database_name-" + database_name)
    print("data_location-" + data_location)
    print("table_domain-" + table_domain)
    print("table_zone-" + table_zone)
    try:
        tab_cols ,tab_param ,tab_description = get_table_schema(table_zone) 
        try:
            create_table(database_name,data_location,table_domain,table_zone,tab_cols ,tab_param ,tab_description)
        except Exception as e:
            print("" + str(e))
    except Exception as e:
        print("Schema not found table can not be created" + str(e)) 
