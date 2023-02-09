def request_data(lat, lon):
    params = {'point': f'{lat},{lon}', 'unit': 'mph', 'thickness': 14, 'key': 'L4P6mCEdDjNejIszYS44dMMlW1n9Imzj'}
    base_url = 'https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/15/json'
    data = requests.get(base_url, params=params).json()
    return data
  

def get_traffic_data(lat, lon):
   data = request_data(lat, lon)
   df = pd.DataFrame()

   df["road_types"] = [data["flowSegmentData"]["frc"]]
   df["currentSpeed"] =[ data["flowSegmentData"]["currentSpeed"]]
   df["freeFlowSpeed"] = [data["flowSegmentData"]["freeFlowSpeed"]]
   df["currentTravelTime"] = [data["flowSegmentData"]["currentTravelTime"]]
   df["freeFlowTravelTime"] = [data["flowSegmentData"]["freeFlowTravelTime"]]
   df["confidence"] = [data["flowSegmentData"]["confidence"]]
   
   return df
  


def create_reply(lat, lon):
    data = request_data(lat, lon)

    road_types = {'FRC0': 'Motorway',
                  'FRC1': 'Major road',
                  'FRC2': 'Other major road',
                  'FRC3': 'Secondary road',
                  'FRC4': 'Local connecting road',
                  'FRC5': 'Local road of high importance',
                  'FRC6': 'Local road'
                  }

    if data['flowSegmentData']['roadClosure']:
        reply = 'Unfortunately this road is closed!'

    else:
        reply = (f"Your nearest road is classified as a _{road_types[data['flowSegmentData']['frc']]}_.  "
                 f"The current average speed is *{data['flowSegmentData']['currentSpeed']} mph* and "
                 f"would take *{data['flowSegmentData']['currentTravelTime']} seconds* to pass this section of road.  "
                 f"With no traffic, the speed would be *{data['flowSegmentData']['freeFlowSpeed']} mph* and would "
                 f"take *{data['flowSegmentData']['freeFlowTravelTime']} seconds*.")

    return reply




-31.352508, -64.180762
lat = -31.352508
lon =-64.180762
for i in range(grid)
prueba =  get_traffic_data(lat, lon)
prueba = request_data(lat, lon)
prueba_reply = create_reply(lat, lon)
