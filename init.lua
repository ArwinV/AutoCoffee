-- Wifi
local SSID = XXXXXXXXX
local PASS = XXXXXXXX

-- Initialise variables
local buttonOnOffPin = 1 --> GPIO5
local buttonReadyPin = 2 --> GPIO4
local buttonCoffee = 8 --> GPIO15
local ledOnOffPin = 6 --> GPIO12
local ledReadyPin = 7 --> GPIO13
local relayOutput = 5 --> GPIO14
local secOneCup = 6 --> Amount of seconds it takes to fill one cup of coffee
local ready = false --> Ready state, coffee won't start if coffee machine is not ready


function button_OnOff()
     --Change on to off and backwards
     if gpio.read(relayOutput) == 1 then
          -- Turn relay off
          gpio.write(relayOutput, gpio.LOW)
          print("Relay off")
          -- Turn led off
          gpio.write(ledOnOffPin, gpio.LOW)
     else
          --Turn relay on
          gpio.write(relayOutput, gpio.HIGH)
          print("Relay on")
          --Turn led on
          gpio.write(ledOnOffPin, gpio.HIGH)
     end
end

function button_Ready()
     -- Change ready led and state
     if ready then
          ready = false
          gpio.write(ledReadyPin, gpio.LOW)
          print("Not ready")
     else
          ready = true
          gpio.write(ledReadyPin, gpio.HIGH)
          print("Ready")
     end
end

function coffee()
     -- Make coffee!
     print("Making coffee...")
     ready = false
     gpio.write(relayOutput, gpio.HIGH)
     tmr.delay(secOneCup*1000000)
     gpio.write(relayOutput, gpio.LOW)
     print("Done!")
end

function autoCoffee()
     -- Must be ready before auto starting to make coffee
     if ready then
          coffee()
     else
          print("Not Ready! You should have filled the coffee machine first.")
     end
end

-- Initilise GPIO pins
gpio.mode(buttonOnOffPin, gpio.INT)
gpio.mode(buttonReadyPin, gpio.INT)
gpio.mode(buttonCoffee, gpio.INT)
gpio.mode(ledOnOffPin, gpio.OUTPUT)
gpio.mode(ledReadyPin, gpio.OUTPUT)
gpio.mode(relayOutput, gpio.OUTPUT)
gpio.trig(buttonOnOffPin, 'up', button_OnOff)
gpio.trig(buttonReadyPin, 'up', button_Ready)
gpio.trig(buttonCoffee, 'up', coffee)

--Initialise wifi
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","PASS")
wifi.sta.connect()

-- Create server
sv = net.createServer(net.TCP, 30)
-- Listen for connection (starts making coffee at every connection, not very clean, but it works)
sv:listen(2000, function(c)
     c:on("receive", function(c,pl)
          print("Incoming connection")
          autoCoffee()
     end)
end)
