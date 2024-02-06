{
  "gps" = {
    "lang": 3342.323, // langitude
    "long": 343243.5 // longitude
  },
    "ultrasonic_sensors" = {
      "isObjectDetected": true // true or false, if obstacle detected
    }
  "gyroscope" = {
    "accelorationX": 10, // measured in units of gravity (g) along X axis
    "accelorationY": 10, // measured in units of gravity (g) along Y axis
    "accelorationZ": 10, // measured in units of gravity (g) along Z axis
    "gyro_X": 15, // gyro raw degrees per second (°/s)
    "gyro_Y": 10, // gyro raw degrees per second (°/s)
    "gyro_Z": 10, // gyro raw degrees per second (°/s)
    "ambientTemperature": 10 // ambient temperature in degrees Celsius (°C).
  }
  "motorDriverModul" = {
    "speedA": 10, // the speed measuret in % from -100 to 100; - is reverse
    "speedB": 10, // the speed measuret in % from -100 to 100; - is reverse
  },
    "battery" = {
      "isCharging": true, // true (charging), false (not charging)
      "state": 10 // how charged is the battery 0 - 100%
    },
    "temperature" = {
      "temperature": 45, // temperature celcius
      "humidity": 45 // humidity %
    },
    "bluetooth" = {
      "isAdmin": true, // true: user has the control; false: lawnmower on its own
      "isConnected": true // if it is connected
    }
  "esc" = {
    "speed": 10 // percentage from 0 to 100 of how fast the blade should cut
  }
  "display" = {
    //TODO if any other info is going to be displayed on display
  }
}
