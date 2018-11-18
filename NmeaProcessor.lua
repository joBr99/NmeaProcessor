-- require 'helper'
require("gps.helper")


NmeaProcessor = {
  --  Validity of latest fix
  valid = false,
  rawTime = "000000",
 	-- Latitude
  latitude = 0,
  -- Longitude
  longitude = 0,
  -- speed
  speed = 0,
  rawDate = "0000000"
  }

function NmeaProcessor:new (o)
     o = o or {}
     setmetatable(o, self)
     self.__index = self
     
     
     return o
end

function NmeaProcessor:isFixValid()
    return self.valid
end

function NmeaProcessor:getHour()
  return tonumber(string.sub(self.rawTime,1,2))
end
function NmeaProcessor:getMinute()
  return tonumber(string.sub(self.rawTime,3,4))
end
function NmeaProcessor:getSecond()
  return tonumber(string.sub(self.rawTime,5,6))
end
function NmeaProcessor:getLongitude()
    return self.longitude
end
function NmeaProcessor:getLatitude()
    return self.latitude
end
function NmeaProcessor:getSpeed()
    return self.speed
end
function NmeaProcessor:getDay()
    return tonumber(string.sub(self.rawDate,1,2))
end
function NmeaProcessor:getMonth()
    return tonumber(string.sub(self.rawDate,3,4))
end
function NmeaProcessor:getYear()
    return tonumber(string.sub(self.rawDate,5,6))
end

function NmeaProcessor:checkSum(line)
  -- Checksum is there
  if string.sub(line,-3,-3) == "*" then
    local val = 0
    -- iterate over each byte
    for c in string.sub(line,2,-4):gmatch(".") do
      val = bxor(val,string.byte(c))
    end
    --Calculated Checksum to HEX
    val = string.format("%02x", val):upper()
    if ( string.sub(line,-2):upper() == val ) then
      return true
    else
      return false
    end
  else
    return true
  end
end

function NmeaProcessor:processline(line)

  if NmeaProcessor:checkSum(line) then

    local data = split(line,",")

    if data[1] == "$GPRMC" then
      
      if string.len(tostring(data[2])) >= 6 then
        self.rawTime = data[2]
      end
      if data[3] == "A" then
        self.valid = true
      else
        self.valid = false
      end
      -- N47° 35.5634 E007° 39.3538

      if data[4] ~= ""  and data[6] ~= "" then
          local long = tonumber(string.sub(data[4],1,2)) + ( tonumber(string.sub(data[4],3)) / 60 )
          if data[5] ~= "N" then
              long = long * -1
          end
          self.longitude = long
   
          local lat = tonumber(string.sub(data[6],1,3)) + ( tonumber(string.sub(data[6],4)) /60 )
          if data[7] ~= "E" then
              lat = lat * -1
          end
          self.latitude = lat
          --self.speed = data[8] -- ??? -> Testing
      end
                  
      if string.len(tostring(data[10])) >= 6 then
        self.rawDate = data[10]
      end

    end
  else
    print("NonValid")
  end
end




-- gps = NmeaProcessor:new(nil)
-- --gps:processline("$GPRMC,163916.00,A,4959.95543,N,00759.87949,E,0.313,,171118,,,A*7B")
-- gps:processline("$GPRMC,0A,49N,00,E,0118,$GPVTG,,T,,M,0.688,N,1.274,K,A*25")
-- 
-- print("Uhrzeit: "..gps:getHour()..":"..gps:getMinute()..":"..gps:getSecond())
-- print('GPS Fix: '..tostring(gps:isFixValid()))
-- print('Longitude: '..gps:getLongitude())
-- print('Latitude: '..gps:getLatitude())
-- print('Altitude: '..gps:getSpeed())
-- print("Datum: "..gps:getDay().."."..gps:getMonth().."."..gps:getYear())
-- 

