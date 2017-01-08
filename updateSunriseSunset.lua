--[[
%% autostart
%% properties
%% globals
--]]

-- Script to set sun to set/risen
-- Remi Bergsma github@remi.nl
-- Inspired by posts on the Fibaro forum http://forum.fibaro.com
-- Updated by Michael Geddes michael@frog.wheelycreek.net

-- Note: This script needs a virtual device (id=90 in example) with two buttons. One to set the sun to 'Risen' and one to 'Set'. They should update the global var 'Sun'.
-- The file Sun.vfib contains the export of this device.

if (fibaro:countScenes() > 1) then  fibaro:abort(); end

-- local vars
local BeforeSunset = 0 
local AfterSunrise = 0
local debug = 0
local ConstVal = {Risen = true,Set = false}

function sunSet()
  fibaro:call(90, "pressButton", "2")
end
function sunRise()
  fibaro:call(90, "pressButton", "1")
end

function checkSunriseSunset()
  local sunriseHour = fibaro:getValue(1,'sunriseHour')
  local sunsetHour = fibaro:getValue(1,'sunsetHour')
  if debug ==1 then fibaro:debug("Today, sunrise is at " .. sunriseHour .. " and sunset at " .. sunsetHour) end

  local tillSunRise = minutesTill(sunriseHour, AfterSunrise)
  local tillSunSet = minutesTill(sunsetHour, -BeforeSunset)

  -- could be null
  local curRisen = ConstVal[fibaro:getGlobalValue("Sun")];
  local newRisen = tillSunRise > tillSunSet
  if curRisen ~= newRisen then
    if newRisen then sunRise() else sunSet() end
  end;
  local timerMins = newRisen and tillSunSet or tillSunRise
  if debug then fibaro:debug( (newRisen and 'Sunset in ' or 'Sunrise in ')..timerMins..' mins'); end
  setTimeout(checkSunriseSunset, timerMins* 60 * 1000)
end

function minutesTill( timeStr, offsetMins )
  local t = os.date("*t")
  local timenow = (t.hour*60)+t.min
  local hh,mm = timeStr:match("(%d+):(%d+)");
  local timethen =  (hh*60)+mm + (offsetMins or 0);
  if (timethen <= timenow) then timethen = timethen + (24*60); end
  return timethen-timenow;
end

checkSunriseSunset()
