--[[
%% properties
%% autostart
%% globals
--]]

-- Script to detect if people are at home, based on their iPhone being on the WiFi network
-- Remi Bergsma github@remi.nl

-- this script has the following requirements to work:
-- 1. iPhonePresenceChecker virtual device, that does the actual checking. See iPhonePresenceChecker.vfib
-- 2. For each person, a virtual device that manages the status of that person. See whereIsRemi.vfib for example. You also need a global var to store its state.
-- 3. Be sure to updat the deviceID's in the virtual devices, as well as in the config below

-- homeStatus device
local homeStatusDeviceID = 48

-- button ids of above device
local homeStatusHomeId = "1"
local homeStatusSleepingId = "2"
local homeStatusAwayId = "3"
local homeStatusHolidayId = "4"

-- phone presence device
local phonePresenceDeviceId = 94

-- phone data array
local phoneDataArray = { 
  { 'Remi', 'remiAtHome', '1' },
  { 'Kaat', 'kaatAtHome', '2' }
}

fibaro:debug("Starting loop..")

while true do
	-- Default: is everybody away. We’ll unset it when we find someone at home
	local allAway = 1

	-- loop each phone to check presence 
	for k, v in pairs(phoneDataArray) do
		personName = v[1]
		globalName = v[2]
		buttonToPress = v[3]

		-- fibaro:debug("Testing " .. personName)
		-- test iPhone
		fibaro:call(phonePresenceDeviceId, "pressButton", buttonToPress)
		-- give it time to update
		fibaro:sleep(2*1000)

		-- someone at home
		if fibaro:getGlobal(globalName) == "1" then
			-- set flag: we’re not all away
			allAway = 0

			-- set homeStatus to Home, if one of us is at home and we’re not already at home or sleeping
			if fibaro:getGlobal("homeStatus") ~= homeStatusHomeId
			and fibaro:getGlobal("homeStatus") ~= homeStatusSleepingId then
				fibaro:debug("At least one of us at home: set homeStatus to Home")
				fibaro:call(homeStatusDeviceID, "pressButton", homeStatusHomeId)
			end
		end
	end

	-- still all away?
	if allAway == 1	and fibaro:getGlobal("homeStatus") ~= homeStatusAwayId then
		fibaro:debug("Everybody is away: set homeStatus to Away")
		fibaro:call(homeStatusDeviceID, "pressButton", homeStatusAwayId) 
	end

	-- only test once a minute
	fibaro:sleep(57*1000)
end
