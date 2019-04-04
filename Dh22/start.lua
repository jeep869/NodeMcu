require ("dh22")
tmr.alarm(2,6000,1,function()
    temp,humi=dh20.readTempHumi()
   print(temp)
   end
)
