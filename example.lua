-- require 'NmeaProcessor'
require("gps.NmeaProcessor")


gps = NmeaProcessor:new(nil)

rserial=io.open("COM4","r")
while true do
line = nil
  while chain==nil do
    line=rserial:read();
    print(line)
    
    
    gps:processline(line)
  --print(line)
    print("Uhrzeit: "..gps:getHour()..":"..gps:getMinute()..":"..gps:getSecond())
    print('GPS Fix: '..tostring(gps:isFixValid()))
    print('Longitude: '..gps:getLongitude())
    print('Latitude: '..gps:getLatitude())
    print('Altitude: '..gps:getSpeed())
    print("Datum: "..gps:getDay().."."..gps:getMonth().."."..gps:getYear())
    
    
    
  end

end