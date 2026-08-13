-- customizable frog fall amounts
return function(TUNING)
    local function ScaleFrogs(key)
        TUNING[key] = math.max(1, math.floor(TUNING[key] * FROG_RAIN_PERCENT))
    end
    ScaleFrogs("FROG_RAIN_MAX")
    ScaleFrogs("FROG_RAIN_LOCAL_MIN")
    ScaleFrogs("FROG_RAIN_LOCAL_MAX")
end