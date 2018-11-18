--require 'NmeaProcessor'
require("gps.NmeaProcessor")

gps = NmeaProcessor:new(nil)

rserial=io.open("/dev/ttyS0","r")
while true do
chain = nil
  while chain==nil do
    chain=rserial:read();
    --print(chain)
    gps:processline(chain)
  end

  if(math.fmod(os.clock()*1000000,50) == 0) then
    print("Uhrzeit: "..gps:getHour()..":"..gps:getMinute()..":"..gps:getSecond())
    print('GPS Fix: '..tostring(gps:isFixValid()))
    print('Longitude: '..gps:getLongitude())
    print('Latitude: '..gps:getLatitude())
    --  print('Altitude: '..gps:getSpeed())
    print("Datum: "..gps:getDay().."."..gps:getMonth().."."..gps:getYear())  end

end


