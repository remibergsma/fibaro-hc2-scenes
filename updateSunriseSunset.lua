--[[
%% autostart
%% properties
%% globals
--]]

-- Script to set sun to set/risen
-- Remi Bergsma github@remi.nl
-- Inspired by posts on the Fibaro forum http://forum.fibaro.com

-- Note: This script needs a virtual device (id=90 in example) with two buttons. One to set the sun to 'Risen' and one to 'Set'. They should update the global var 'Sun'.
-- The file Sun.vfib contains the export of this device.

-- local vars
local sunriseHour = fibaro:getValue(1,'sunriseHour') 
local sunsetHour = fibaro:getValue(1,'sunsetHour') 
local BeforeSunset = 0 
local AfterSunrise = 0
local debug = 0

while true do 
  sunriseHour = fibaro:getValue(1,'sunriseHour') 
  sunsetHour = fibaro:getValue(1,'sunsetHour')
  if debug ==1 then fibaro:debug("Today, sunrise is at " .. sunriseHour .. " and sunset at " .. sunsetHour) end
  if (os.date("%H:%M", os.time()+BeforeSunset*60) >= sunsetHour) 
    or (os.date("%H:%M", os.time()-AfterSunrise*60) < sunriseHour) 
      then 
        -- sun is set
        if (fibaro:getGlobalValue("Sun") ~= "Set")
          then
            fibaro:call(90, "pressButton", "2")
            if debug ==1 then fibaro:debug("Changed sunset var to Set") end
          end
      else
        -- sun is risen
        if (fibaro:getGlobalValue("Sun") ~= "Risen")
          then
            fibaro:call(90, "pressButton", "1")
            if debug ==1 then fibaro:debug("Changed sunset var to Risen") end
        end
  end
  -- running once a minute is enough
  fibaro:sleep(60000)
end
