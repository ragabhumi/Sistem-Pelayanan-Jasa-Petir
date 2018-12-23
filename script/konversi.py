import pandas
import json
import sys
import os
import shutil
import datetime

data=sys.argv[1]
bujur=float(sys.argv[2])
lintang=float(sys.argv[3])
jam_awal=sys.argv[4]
jam_akhir=sys.argv[5]



offset=1 #dalam derajat
tahun=data[0:4]
bulan=data[4:6]
tanggal=data[6:8]
namabulan=['JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI','JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER']

start_date_wib=pandas.to_datetime(str(tahun)+'-'+str(bulan)+'-'+str(tanggal)+' '+jam_awal+':00', format='%Y%m%d %H:%M:%S')
start_date_utc=start_date_wib-pandas.Timedelta('7 hours')
end_date_wib=pandas.to_datetime(str(tahun)+'-'+str(bulan)+'-'+str(tanggal)+' '+jam_akhir+':00', format='%Y%m%d %H:%M:%S')
end_date_utc=end_date_wib-pandas.Timedelta('7 hours')

datapetir='E:\\DATABASE\\ARCHIVE\\NGXDATA_RANDOM_CSV\\' + tahun + '\\' + namabulan[int(bulan)-1] + '\\rnd_' + str(data) + '.csv'

if (os.path.isfile(datapetir)==False or os.stat(datapetir).st_size==0):
    shutil.copyfile('..\\data\\default.geojson','..\\data\\petir.geojson')
else:
    df = pandas.read_csv(datapetir,
        parse_dates=[
            'datetime_utc',
        ],
        infer_datetime_format=True,
        na_values=['']
    )
    
    df.columns = ['id','epoch_ms','time','latitude','longitude','type']
    df = df[(df['latitude'] >= lintang-offset) & (df['latitude'] <= lintang+offset)]
    df = df[(df['longitude'] >= bujur-offset) & (df['longitude'] <= bujur+offset)]
    mask = (df['time'] > start_date_utc) & (df['time'] <= end_date_utc)
    df = df.loc[mask]
    df['time'] = df['time'].dt.strftime('%Y-%m-%d %H:%M:%S')
    #Hapus tipe 2 (IC)
    df = df[df.type!=2]

    json_result_string = df.to_json(
        orient='records', 
        double_precision=12,
        date_format='iso'
    )

    json_result = json.loads(json_result_string)


    geojson = {
        'type': 'FeatureCollection',
        'features': []
    }
    for record in json_result:
        geojson['features'].append({
            'type': 'Feature',
            'geometry': {
                'type': 'Point',
                'coordinates': [record['longitude'], record['latitude']],
            },
            'properties': record,

        })
        
    with open('..\\data\\petir.geojson', 'w') as f:
        f.write(json.dumps(geojson, indent=2))
    