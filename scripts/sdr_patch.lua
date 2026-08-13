-- upgrade persistance patch for Stronger Drying Rack mod
return function(AddComponentPostInit)
    AddComponentPostInit("upgradeable", function(self)
        if self.inst.prefab == "meatrack" then
            self.numstages = 1
            self.upgradesperstage = 1

            local old_CanUpgrade = self.CanUpgrade
            self.CanUpgrade = function(self)
                if self.inst.prefab == "meatrack" then
                    return (self.numupgrades or 0) == 0
                end
                return old_CanUpgrade(self)
            end
        end

        local old_OnLoad = self.OnLoad
        self.OnLoad = function(self, data)
            old_OnLoad(self, data)
            if self.inst.prefab == "meatrack" and self.numupgrades and self.numupgrades > 0 and self.inst.components.container ~= nil then
                self.inst.components.container:EnableInfiniteStackSize(true)
            end
        end
    end)
end