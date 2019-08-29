local moduleName = ...
local M = {}
_G[moduleName] = M
local id  = 0
local sda = 5
local scl = 6
local dev_addr = 0x44 
local delay=14 

function M.read()
    -- send command
    i2c.start(id)
    ack = i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, 0x2C, 0x06) 
    i2c.stop(id)
    tmr.delay(delay)
    -- get data
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    data = i2c.read(id, 6)
    i2c.stop(id)
    temp = (((((data:byte(1) * 256) + data:byte(2)) * 1750) / 65535) - 450)/10+0.05
    humi = ((((data:byte(4) * 256) + data:byte(5)) * 1000) / 65535)/10+0.05
    --print("temperature="..(temp-temp%0.1)..", humidity="..(humi-humi%0.1))
    return temp-temp%0.1,humi-humi%0.1
end    

function M.init()
   i2c.setup(id, sda, scl, i2c.SLOW)  
end

return M
