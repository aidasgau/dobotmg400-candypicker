-- Version: Lua 5.3.5DI(1)
-- The inputs of this program work in a reverse mode
-- Meaning that if the inputs are in OFF state then we act (signal is received from raspberry)
-- Otherwise if the input is ON, that means no signal was received yet and we keep waiting for it

-- First Candy origins
local origin_ananasas = {-70, 339, -140, 240}
local origin_fortuna = {-71, -277, -140, 240}

-- Offset distances between candy slot rows and columns
local offset_x = 50
local offset_y = -90

-- Input Pins
local pin_in_ananasas = 1
local pin_in_fortuna = 2

-- Output Pins
local pin_out_feedback = 1


-- Offset for descending to a candy after choosing it
local descend_offset_z = 9

-- Drop off origin coordinate
local origin_dropoff = {290,0, 120, 160}

-- Next candy positions
local next_ananasas = 0
local next_fortuna = 0

-- Get the coordinates of the next candy based on the given inputs
-- If both inputs are selected (OFF), select ananasas; if neither is , return nil
function next_coords(input_ananasas, input_fortuna)
    local origin, next_candy

    if input_ananasas == OFF then
        origin = origin_ananasas
        next_candy = next_ananasas
        next_ananasas = (next_candy + 1) % 8
    elseif input_fortuna == OFF then
        origin = origin_fortuna
        next_candy = next_fortuna
        next_fortuna = (next_candy + 1) % 8
    else
        return nil
    end
    local x = origin[1] + (next_candy % 4) * offset_x
    local y = origin[2] + math.floor(next_candy / 4) * offset_y
    --Returning the calculated coords for the currently selected candy to pick up
    return {x, y, origin[3], origin[4]}
end

-- Function to descend to a candy and turn on the Digital Output for Suction
-- Coords parameter represents the current coordinates of the robot's hand
function pickup_drop(coords)
  coords[3] = coords[3] - descend_offset_z
  MovJ({coordinate = coords, sync = true})
  Sleep(1000)
  DO(7, ON)
  Sleep(1000)
  coords[3] = coords[3] + descend_offset_z + 10
  MovJ({coordinate = coords, sync = true})
  MovJ({coordinate = origin_dropoff, sync = true})
  DO(7, OFF)
end

-- This function calls the next_coords to get the coordinates of the candy to pickup and then
-- Moves to the candy
-- Finally it calls the pickup_drop to actually pick up the candy
function grab_candy(input_ananasas, input_fortuna)
  local coords = next_coords(input_ananasas, input_fortuna)
  if coords ~= nil then
    MovJ({coordinate = coords, sync = true})
    pickup_drop(coords)
  end
end

-- Main program loop
function main()
  while(true)
  do
    input_ananasas = DI(pin_in_ananasas)
    input_fortuna = DI(pin_in_fortuna)
    if input_ananasas == OFF or input_fortuna == OFF then
      print("Received signal")
      grab_candy(input_ananasas, input_fortuna)
      DO(pin_out_feedback, ON)
      print("Sending output")
      Sleep(2500)
      DO(pin_out_feedback, OFF)
      print("Returning to base")
    end
  end
end

-- We call main here to start the program
main()
--end
