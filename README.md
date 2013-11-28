## Reaction Time Test

![Icon](ReactionTime/Images.xcassets/AppIcon.appiconset/Icon60@2x.png)

### Setup

`pod install`

`open ReactionTime.xcworkspace`

### How to Use

You can configure the API endpoint this app posts to in the settings screen of the app. 
Once an endpoint is configured, the app will post test results to that endpoint 
after a test is complete.

The app logs test results while offline and will send all results after the app comes 
back online.


### Sample Post Request

Here is a sample post request that is sent from the app.

```
{
  "entries": [
    {
      "timestamp": 1385146362,
      "date": "2013-11-22T10:52:42-0800"
      "timezone": {
        "abbr": "PST",
        "name": "America/Los_Angeles",
        "offset": -28800
      },
      "delay": 748,
      "tap_location": {
        "x": 144,
        "y": 472
      },
      "target_location": {
        "x": 135,
        "y": 450
      },
      "tap_diff": {
        "x": 8,
        "y": 22
      },
      "percent": {
        "x": 95.48,
        "y": 95.15,
        "overall": 9531.56
      },
      "geo_location": {
        "latitude": 37.33065347,
        "longitude": -122.02950551,
        "accuracy": 10,
        "altitude": 0,
        "speed": 3,
        "timestamp": 1385657753
      }
    }
  ]
}
```

There may be more than one entry depending on how long it has been since the last time
the entries were successfully synced.

### License

Copyright 2013 by Aaron Parecki

Licensed under the Apache license. See LICENSE.

