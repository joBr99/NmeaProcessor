--require 'helper'
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
  if(string.find(line, "*") ~= nil) then
    locChecksum = string.find(line, "*")+1
    local val = 0
    local val_before = 0
    -- iterate over each byte

    --print("_DEBUG_ : "..line)
    --print("_DEBUG_ : "..string.sub(line,2,locChecksum-2))

    for c in string.sub(line,2,locChecksum-1):gmatch(".") do
      val_before = val
      val = bxor(val,string.byte(c))
      --print("_DEBUG_ : "..string.format("%02x", val):upper())
    end
    --Calculated Checksum to HEX
    val = string.format("%02x", val_before):upper()

    --print("_DEBUG_ Calc CheckSum: "..val.." : "..val_before.."   StrChecksum: "..string.sub(line,locChecksum,locChecksum+2):upper())
    --print("_DEBUG_ "..string.sub(line,locChecksum,locChecksum+2):upper().." "..val)
    --if ( string.sub(line,locChecksum,locChecksum+2):upper() == val ) then
    if ( string.find(string.sub(line,locChecksum,locChecksum+2):upper(), val) ) then
      return true
    else
      return false
    end
  else
    return false
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
    --print("NonValid")
  end
end
