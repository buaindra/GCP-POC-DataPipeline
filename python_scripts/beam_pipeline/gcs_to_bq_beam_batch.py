import apache_beam as beam
import argparse
from sys import argv
from apache_beam.options.pipeline_options import PipelineOptions


project_id = "indranil-24011994-03export"
v_schema = "Symbol:STRING,Open:FLOAT,High:FLOAT,Low:FLOAT,LTP:FLOAT,Chng:FLOAT,PCChng:FLOAT,Volume:FLOAT, \
    Turnover:FLOAT,_52w_H:FLOAT,_52w_L:FLOAT,_365d_PC_chng:FLOAT,_30d_PC_chng:FLOAT"



def discard_incomplete(data):
    return len(data["Symbol"]) > 0

def convert_types(data):
    data["Open"] = float(str(data["Open"]).replace(",","").replace("\"","")) if "Open" in data else None
    data["High"] = float(str(data["High"]).replace(",","").replace("\"","")) if "High" in data else None
    data["Low"] = float(str(data["Low"]).replace(",","").replace("\"","")) if "Low" in data else None
    data["LTP"] = float(str(data["LTP"]).replace(",","").replace("\"","")) if "LTP" in data else None
    data["Chng"] = float(str(data["Chng"]).replace(",","").replace("\"","")) if "Chng" in data else None
    data["PCChng"] = float(str(data["PCChng"]).replace(",","").replace("\"","")) if "PCChng" in data else None
    data["Volume"] = float(str(data["Volume"]).replace(",","").replace("\"","")) if "Volume" in data else None
    data["Turnover"] = float(str(data["Turnover"]).replace(",","").replace("\"","")) if "Turnover" in data else None
    data["_52w_H"] = float(str(data["_52w_H"]).replace(",","").replace("\"","")) if "_52w_H" in data else None
    data["_52w_L"] = float(str(data["_52w_L"]).replace(",","").replace("\"","")) if "_52w_L" in data else None
    data["_365d_PC_chng"] = float(str(data["_365d_PC_chng"]).replace(",","").replace("\"","")) if "_365d_PC_chng" in data else None
    data["_30d_PC_chng"] = float(str(data["_30d_PC_chng"]).replace(",","").replace("\"","")) if "_30d_PC_chng" in data else None
    return data


def del_unwanted_cols(data):
    del data["PCChng"]
    del data["Turnover"]
    return data


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    known_args = parser.parse_known_args(argv)

    p = beam.Pipeline(options=PipelineOptions())

    (p | 'ReadData' >> beam.io.ReadFromText('gs://poc01-330806/input/National_Stock_Exchange_of_India_Ltd.csv', skip_header_lines =1)
       | 'SplitData' >> beam.Map(lambda x: x.split(','))
       | 'FormatToDict' >> beam.Map(lambda x: {"Symbol": x[0],"Open": x[1],"High": x[2],"Low": x[3],"LTP": x[4],"Chng": x[5],\
            "PCChng": x[6],"Volume": x[7],"Turnover": x[8],"_52w_H": x[9],"_52w_L": x[10],"_365d_PC_chng": x[11],"_30d_PC_chng": x[12]}) 
       | 'DeleteIncompleteData' >> beam.Filter(discard_incomplete)
       | 'ChangeDataType' >> beam.Map(convert_types)
       | 'DeleteUnwantedData' >> beam.Map(del_unwanted_cols)
       | 'WriteToBigQuery' >> beam.io.WriteToBigQuery(
           '{0}:poc_dataflow.detailed_view'.format(project_id),
           schema=v_schema,
           write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND))
    result = p.run()
    result.wait_until_finish()
