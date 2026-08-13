---------- REGISTERED MOD COMMANDS ----------

-- clears and rerolls the wandering trader's offerings
function _G.c_resetTrades()
    local trader = c_findnext("wanderingtrader")
    trader.components.craftingstation:ForgetAllItems()
    trader:RerollWares()
end