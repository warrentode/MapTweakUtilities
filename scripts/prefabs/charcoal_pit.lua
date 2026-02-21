require "prefabutil"

local assets = {
    Asset("ANIM", "anim/charcoal_pit.zip"),
    Asset("ATLAS", "images/inventoryimages/charcoal_pit.xml"),
}

local prefabs = {
    "collapse_small",
    "charcoal",
}

local MACHINESTATES = {
    ON = "_on",
    OFF = "_off",
}

--- created boolean here since it was dropping product on login when not turned on after my other changes
local justLoaded = true
local function OnLoad()
    justLoaded = false
end

--- set up config options for the ash drop chances
local ash1_chance = GetModConfigData("ash1_chance", "Map Tweak Utilities") or 1
local ash2_chance = GetModConfigData("ash2_chance", "Map Tweak Utilities") or 0.5

--- I put back the sound effects and synced the animations to the actual behavior of the structure
--- also I removed the unused bits left in here to declutter the code

local function spawncharcoal(inst)
    --- removed the callback removal for the use anim since it's no longer needed here
    --- fixed the spawn of one ash when it shouldn't be spawning and simplified the spawn positions

    -- base position of the pit
    local x, y, z = inst.Transform:GetWorldPosition()

    local charcoal = SpawnPrefab("charcoal")
    charcoal.Transform:SetPosition(x, y + 2, z)

    if math.random() < ash1_chance then
        local ash1 = SpawnPrefab("ash")
        ash1.Transform:SetPosition(x, y + 2, z + 0.3)
    end

    if math.random() < ash2_chance then
        local ash2 = SpawnPrefab("ash")
        ash2.Transform:SetPosition(x + 0.3, y + 2, z)
    end

    --- removed anim here and replaced with sound
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
end

local function onhammered(inst, _)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
    inst:Remove()
end

local function fueltaskfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")
    inst.AnimState:PlayAnimation("use")
    inst.components.fueled:StopConsuming()
    --- replaced event listener call with a delayed call to get the correct visual timing
    inst:DoTaskInTime(0.5, function(inst)
        spawncharcoal(inst)
    end)
end

local function ontakefuelfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    inst.components.fueled:StartConsuming()
end

local function fuelupdatefn(inst, _)
    inst.components.fueled.rate = 1
end

local function onhit(inst, _)
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
    inst.AnimState:PlayAnimation("hit" .. inst.machinestate)
    inst.AnimState:PushAnimation("idle" .. inst.machinestate, true)
    inst:RemoveEventCallback("animover", spawncharcoal)
    if inst.machinestate == MACHINESTATES.ON then
        inst.components.fueled:StartConsuming()
    end
end

local function fuelsectioncallback(new, old, inst)
    if new == 0 and old > 0 then
        inst.machinestate = MACHINESTATES.OFF
        inst.AnimState:PlayAnimation("turn" .. inst.machinestate)
        inst.AnimState:PushAnimation("idle" .. inst.machinestate, true)
        inst.SoundEmitter:KillSound("loop")
        inst.Light:Enable(false)
        --- set to allow fueling
        inst.components.fueled.accepting = true
        --- drop the product directly here rather than handling it as a task
        if not justLoaded then
            fueltaskfn(inst)
        end
    elseif new > 0 and old == 0 then
        inst.machinestate = MACHINESTATES.ON
        inst.AnimState:PlayAnimation("turn" .. inst.machinestate)
        inst.AnimState:PushAnimation("idle" .. inst.machinestate, true)
        if not inst.SoundEmitter:PlayingSound("loop") then
            inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "loop")
        end
        inst.Light:Enable(true)
        --- set to block fueling
        inst.components.fueled.accepting = false
    end
end

local function getstatus(inst)
    local sec = inst.components.fueled:GetCurrentSection()
    if sec == 0 then
        return "OUT"
    elseif sec <= 4 then
        local t = {"VERYLOW", "LOW", "NORMAL", "HIGH"}
        return t[sec]
    end
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/cook_pot_craft")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle" .. inst.machinestate)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetIcon("charcoal_pit.tex")

    inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235 / 255, 62 / 255, 12 / 255)

    inst:AddTag("structure")

    inst.AnimState:SetBank("charcoal_pit")
    inst.AnimState:SetBuild("charcoal_pit")

    MakeSnowCoveredPristine(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("lootdropper")
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.SEG_TIME
    inst.components.fueled.accepting = true
    inst.components.fueled:SetSections(4)
    inst.components.fueled.ontakefuelfn = ontakefuelfn
    inst.components.fueled:SetUpdateFn(fuelupdatefn)
    inst.components.fueled:SetSectionCallback(fuelsectioncallback)
    inst.components.fueled:InitializeFuelLevel((TUNING.SEG_TIME * 3) / 2)
    inst.components.fueled:StartConsuming()

    inst.components.fueled.CanAcceptFuelItem = function(self, item)
        --- based on original code, it looked like the author only wanted logs and living logs useable as fuel but it wasn't doing that, so I fixed that
        if self.accepting and (item.prefab == "log" or item.prefab == "livinglog") then
            return true
        end
        return false
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    --- replaced the default machinestate here with boolean setter
    inst:DoTaskInTime(1, function(inst) OnLoad(inst) end)

    return inst
end

return Prefab("charcoal_pit", fn, assets, prefabs),
MakePlacer("charcoal_pit_placer", "charcoal_pit", "charcoal_pit", "idle_off")