
local tb = {}
local id  = 0
local sda = 2 -- pin D2
local scl = 1 -- pin D1
local dev_addr = 0x44 --
local delay=14 -- 13500us


function tb.show()
    print("it is ok")
end

local function get_data2()
    local data, temp, humi, msg

    -- get data
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    data = i2c.read(id, 6) -- read 6 bytes
    i2c.stop(id)

    -- calculate temperature and humidity (2 data bytes + 1 checksum byte)
    temp = ((((data:byte(1) * 256) + data:byte(2)) * 1750) / 65535) - 450
    humi = ((((data:byte(4) * 256) + data:byte(5)) * 1000) / 65535)
    print("temperature="..(temp/10).."."..(temp%10)..", humidity="..(humi/10).."."..(humi%10))


end

function tb.get_data()
    -- send command
    i2c.start(id)
    ack = i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, 0x2C, 0x06) -- HIGH Repeatability, Clock stretching ENABLED
    i2c.stop(id)

    tmr.create():alarm(delay, tmr.ALARM_SINGLE, get_data2)
end


function tb.init_sht()

    i2c.setup(id, sda, scl, i2c.SLOW)   --(id, pinSDA, pinSCL, speed)

end
return tb
