m_dis = {}

function dispatch(m, t, pl)
    if pl ~= nil and m_dis[t] then
        m_dis[t](m, pl)
    end
end

function scriptfunc(m, pl)
    node.input(pl)
end

function powerfunc(m, pl)
    v = adc.readvdd33() / 1000
    m:publish("sensor/power", v, 0, 0)
end

function restartfunc(m, pl)
    node.restart()
end

function updatefunc(m, pl)
    local pack = sjson.decode(pl)
    if pack.content then

        if pack.cmd == "open" then file.open(pack.content, "w+")

        elseif pack.cmd == "write" then file.write(pack.content)

        elseif pack.cmd == "close" then file.close()

        elseif pack.cmd == "remove" then file.remove(pack.content)

        elseif pack.cmd == "run" then dofile(pack.content)

        elseif pack.cmd == "read" then pubfile(m, pack.content)

        elseif pack.cmd == "add" then file.open(pack.content, "a+")
        end
    end
end

function uartfunc(m, pl)
    uart.write(0, pl)
end

function handle_mqtt_error(client, reason)
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

function do_mqtt_connect()
    m:connect("你的阿波罗地址", 端 口 号 , 0 , 0 , function (client) print ("try to connect") end , handle_mqtt_error)
    m:on("connect",
        function(con)
            m:subscribe("sensor/script", 2, function(m) end)
            m:subscribe("sensor/power", 2, function(m) end)
            m:subscribe("sensor/restart", 2, function(m) end)
            m:subscribe("sensor/update", 2, function(m) end)
            m:subscribe("sensor/uart", 2, function(m) end)
            m:publish("initDone", "SUCCESS", 0, 0)
            if file.exists("initSerial.lua") then
                dofile("initSerial.lua")
            end
        end)
end

m_dis["sensor/script"] = scriptfunc
m_dis["sensor/power"] = powerfunc
m_dis["sensor/update"] = updatefunc
m_dis["sensor/restart"] = restartfunc
m_dis["sensor/uart"] = uartfunc

m = mqtt.Client("0", 60, "用户名", "密码")
m:lwt("/lwt", "0", 0, 0)
m:on("offline", function(con) do_mqtt_connect() end)
m:on("message", dispatch)
do_mqtt_connect()
