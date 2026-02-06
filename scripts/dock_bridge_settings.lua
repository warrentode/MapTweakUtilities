-- custom settings for dock and bridge

return function(Vector3, IsLandTile, TileGroupManager, AddPrefabPostInit, WORLD_TILES, TUNING, config)
    local DOCK_KIT_PLACEMENT_OVERRIDE = config.DOCK_KIT_PLACEMENT_OVERRIDE
    local ROPEBRIDGE_MAX_LENGTH = config.ROPEBRIDGE_MAX_LENGTH

    ---------- DOCK KIT PLACEMENT CONTROLS ----------

    local function IsPermanentOrDockFilterFn(tileid)
        return IsLandTile(tileid) and not (TileGroupManager:IsTemporaryTile(tileid) and tileid ~= WORLD_TILES.FARMING_SOIL and tileid ~= WORLD_TILES.MONKEY_DOCK)
    end

    local function CLIENT_CanDeployDockKit(inst, pt, mouseover, _, _)
        local x, _, z = pt:Get()
        local tile = TheWorld.Map:GetTileAtPoint(x, 0, z)

        if tile == WORLD_TILES.OCEAN_COASTAL or
                tile == WORLD_TILES.OCEAN_SWELL or
                tile == WORLD_TILES.OCEAN_ROUGH or
                tile == WORLD_TILES.OCEAN_HAZARDOUS or
                tile == WORLD_TILES.OCEAN_BRINEPOOL then
            return true
        end

        local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, 0, z)
        if not TheWorld.Map:HasAdjacentTileFiltered(tx, ty, IsPermanentOrDockFilterFn) then
            return false
        end

        local center_pt = Vector3(TheWorld.Map:GetTileCenterPoint(tx, ty))
        return TheWorld.Map:CanDeployDockAtPoint(center_pt, inst, mouseover)
    end

    if DOCK_KIT_PLACEMENT_OVERRIDE then
        AddPrefabPostInit("dock_kit", function(inst)
            inst._custom_candeploy_fn = CLIENT_CanDeployDockKit
        end)
    end

    ---------- ROPE BRIDGE CONTROLS ----------

    TUNING.ROPEBRIDGE_LENGTH_TILES = ROPEBRIDGE_MAX_LENGTH
end