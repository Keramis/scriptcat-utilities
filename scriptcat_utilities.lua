util.keep_running()
require("Universal_ped_list")
require("Universal_objects_list")
require("natives-1640181023")
local menuroot = menu.my_root()
local menuAction = menu.action
local menuToggle = menu.toggle
local menuToggleLoop = menu.toggle_loop
local joaat = util.joaat
local wait = util.yield
local getEntityCoords = ENTITY.GET_ENTITY_COORDS
local getPlayerPed = PLAYER.GET_PLAYER_PED

local ESPlist = menu.list(menuroot, "ESP", {}, "")

menu.divider(ESPlist, "ScriptCat ESP")
--preload
DIST_RED = 25
DIST_ORANGE = 50
DIST_YELLOW = 100
DIST_GREEN = 200
DIST_BLUE = 500

DIST_REDSQ = DIST_RED^2
DIST_ORANGESQ = DIST_ORANGE^2
DIST_YELLOWSQ = DIST_YELLOW^2
DIST_GREENSQ = DIST_GREEN^2
DIST_BLUESQ = DIST_BLUE^2

menuToggleLoop(ESPlist, "ESP Experimental", {"expesp"}, "", function ()
    for i = 0, 31 do
        if i ~= players.user() then
            local coord = getEntityCoords(getPlayerPed(i))
            local pointx = memory.alloc()
            local pointy = memory.alloc()
            if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coord.x, coord.y, coord.z, pointx, pointy) then
                local x = memory.read_float(pointx)
                local y = memory.read_float(pointy)
                local myCoords = getEntityCoords(getPlayerPed(players.user()))
                local distsq = SYSTEM.VDIST2(myCoords.x, myCoords.y, myCoords.z, coord.x, coord.y, coord.z) --distance is square rooted, faster that way.
                if distsq <= DIST_REDSQ then
                    local cc = {r = 1.0, g = 0.0, b = 0.0, a = 1.0} --red
                    directx.draw_line(0.5, 1.0, x, y, cc)

                elseif distsq <= DIST_ORANGESQ then
                    local cc = {r = 1.0, g = 0.498, b = 0.0, a = 1.0} --orange
                    directx.draw_line(0.5, 1.0, x, y, cc)

                elseif distsq <= DIST_YELLOWSQ then
                    local cc = {r = 1.0, g = 1.0, b = 0.0, a = 1.0} --yellow
                    directx.draw_line(0.5, 1.0, x, y, cc)

                elseif distsq <= DIST_GREENSQ then
                    local cc = {r = 0.0, g = 1.0, b = 0.0, a = 1.0} --green
                    directx.draw_line(0.5, 1.0, x, y, cc)

                elseif distsq <= DIST_BLUESQ then
                    local cc = {r = 0.0, g = 0.0, b = 1.0, a = 1.0} --blue
                    directx.draw_line(0.5, 1.0, x, y, cc)

                else
                    local cc = {r = 1.0, g = 1.0, b = 1.0, a = 1.0} --white
                    directx.draw_line(0.5, 1.0, x, y, cc)

                end
            end
            memory.free(pointx)
            memory.free(pointy)
        end
    end
end)

menu.slider(ESPlist, "ESP Red Distance", {"espred"}, "Red color.", 1, 1000000, 25, 10, function (value)
    DIST_RED = value
    wait(10)
    DIST_REDSQ = DIST_RED^2
end)

menu.slider(ESPlist, "ESP Orange Distance", {"esporange"}, "Orange color.", 1, 1000000, 50, 10, function (value)
    DIST_ORANGE = value
    wait(10)
    DIST_ORANGESQ = DIST_ORANGE^2
end)

menu.slider(ESPlist, "ESP Yellow Distance", {"espyellow"}, "Yellow color.", 1, 1000000, 100, 10, function (value)
    DIST_YELLOW = value
    wait(10)
    DIST_YELLOWSQ = DIST_YELLOW^2
end)

menu.slider(ESPlist, "ESP Green Distance", {"espgreen"}, "Green color.", 1, 1000000, 200, 10, function (value)
    DIST_GREEN = value
    wait(10)
    DIST_GREENSQ = DIST_GREEN^2
end)

menu.slider(ESPlist, "ESP Blue Distance", {"espblue"}, "Blue color.", 1, 1000000, 500, 10, function (value)
    DIST_BLUE = value
    wait(10)
    DIST_BLUESQ = DIST_BLUE^2
end)

menu.divider(menuroot, "Test features")

--------------------------------------------------------------------------------------------------------------------------

local function rqModel (hash)
    STREAMING.REQUEST_MODEL(hash)
    local count = 0
    util.toast("Requesting model...")
    while not STREAMING.HAS_MODEL_LOADED(hash) and count < 100 do
        STREAMING.REQUEST_MODEL(hash)
        count = count + 1
        wait(10)
    end
    if not STREAMING.HAS_MODEL_LOADED(hash) then
        util.toast("Tried for 1 second, couldn't load this specified model!")
    end
end

local function spawnPedOnPlayer(hash, pid)
    rqModel(hash)
    local lc = getEntityCoords(getPlayerPed(pid))
    local pe = entities.create_ped(26, hash, lc, 0)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return pe
end

local function spawnObjectOnPlayer(hash, pid)
    rqModel(hash)
    local lc = getEntityCoords(getPlayerPed(pid))
    local ob = entities.create_object(hash, lc)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return ob
end

PED_HEX = 0
PED_STR = 0
PED_INT = 0

local function playerSetup(pid)
    menu.divider(menu.player_root(pid), "ScriptCat-Features")
    menuToggleLoop(menu.player_root(pid), "ESP On Player", {"expesp"}, "", function ()
        local coord = getEntityCoords(getPlayerPed(pid))
        local pointx = memory.alloc()
        local pointy = memory.alloc()
        if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coord.x, coord.y, coord.z, pointx, pointy) then
            local x = memory.read_float(pointx)
            local y = memory.read_float(pointy)
            local myCoords = getEntityCoords(getPlayerPed(players.user()))
            local distsq = SYSTEM.VDIST2(myCoords.x, myCoords.y, myCoords.z, coord.x, coord.y, coord.z) --distance is square rooted, faster that way.
            if distsq <= DIST_REDSQ then
                local cc = {r = 1.0, g = 0.0, b = 0.0, a = 1.0} --red
                directx.draw_line(0.5, 1.0, x, y, cc)

            elseif distsq <= DIST_ORANGESQ then
                local cc = {r = 1.0, g = 0.498, b = 0.0, a = 1.0} --orange
                directx.draw_line(0.5, 1.0, x, y, cc)

            elseif distsq <= DIST_YELLOWSQ then
                local cc = {r = 1.0, g = 1.0, b = 0.0, a = 1.0} --yellow
                directx.draw_line(0.5, 1.0, x, y, cc)

            elseif distsq <= DIST_GREENSQ then
                local cc = {r = 0.0, g = 1.0, b = 0.0, a = 1.0} --green
                directx.draw_line(0.5, 1.0, x, y, cc)

            elseif distsq <= DIST_BLUESQ then
                local cc = {r = 0.0, g = 0.0, b = 1.0, a = 1.0} --blue
                directx.draw_line(0.5, 1.0, x, y, cc)

            else
                local cc = {r = 1.0, g = 1.0, b = 1.0, a = 1.0} --white
                directx.draw_line(0.5, 1.0, x, y, cc)

            end
        end
        memory.free(pointx)
        memory.free(pointy)
    end)
    local spawnp = menu.list(menu.player_root(pid), "Spawn Ped On Player", {}, "")
    menu.text_input(spawnp, "Hex Hash", {"pedhex"}, "Set the hex hash for spawning the ped.", function (str)
        PED_HEX = str
    end, "0")
    menu.action(spawnp, "Spawn Ped HEX", {}, "Spawns the ped using hex.", function ()
        if PED_HEX ~= 0 then
            spawnPedOnPlayer(PED_HEX, pid)
        else
            util.toast("No model selected!")
        end
    end)
    menu.text_input(spawnp, "String Name", {"pedstring"}, "Set the string name for spawning the ped.", function (str)
        PED_STR = util.joaat(tostring(str))
    end, "0")
    menu.action(spawnp, "Spawn Ped STRING", {}, "Spawns the ped using the string.", function ()
        if PED_STR ~= 0 then
            spawnPedOnPlayer(PED_STR, pid)
        else
            util.toast("No model selected!")
        end
    end)
end

local whitecolor = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
local nameObjList = menu.list(menuroot, "Render Objects", {}, "")
menu.divider(nameObjList, "Render")
menuToggleLoop(nameObjList, "Render Objects", {}, "This will give you the HEX HASH of objects near you.", function ()
    local objTable = entities.get_all_objects_as_pointers()
    for i = 1, #objTable do
        local Objpos = entities.get_position(objTable[i])
        local pedPos = getEntityCoords(getPlayerPed(players.user()))
        local vdist2 = SYSTEM.VDIST2(pedPos.x, pedPos.y, pedPos.z, Objpos.x, Objpos.y, Objpos.z)
        if vdist2 <= 625 then
            local modelname = entities.get_model_hash(objTable[i])
            local modelname2 = string.format("0x%08X", modelname)
            local sx = memory.alloc()
            local sy = memory.alloc()
            if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(Objpos.x, Objpos.y, Objpos.z, sx, sy) then
                local ssx = memory.read_float(sx)
                local ssy = memory.read_float(sy)
                --directx.draw_text(ssx, ssy, tostring(modelname), 1, 1, whitecolor, false)
                directx.draw_text(ssx, ssy - 0.1, tostring(modelname2), 1, 1, whitecolor, false)
                directx.draw_line(0.5, 1.0, ssx, ssy, whitecolor)
            end
            memory.free(sx)
            memory.free(sy)
        end
    end
end)

SPAWNED_PEDS = {}
SPAWNED_PEDS_COUNT = 0
local spawnerList = menu.list(menuroot, "Spawner", {}, "")
local spawnPeds = menu.list(spawnerList, "Spawn Peds", {}, "")
menu.action(spawnPeds, "Cleanup all spawned peds", {}, "", function ()
    if SPAWNED_PEDS_COUNT ~= 0 then
        for i = 1, SPAWNED_PEDS_COUNT do
            entities.delete_by_handle(SPAWNED_PEDS[i])
        end
        SPAWNED_PEDS_COUNT = 0
    else
        util.toast("No peds left!")
    end
end)
for i = 1, #UNIVERSAL_PEDS_LIST do
    menu.action(spawnPeds, "Spawn " .. tostring(UNIVERSAL_PEDS_LIST[i]), {"catspawnped " .. tostring(UNIVERSAL_PEDS_LIST[i])}, "", function ()
        SPAWNED_PEDS_COUNT = SPAWNED_PEDS_COUNT + 1
        SPAWNED_PEDS[SPAWNED_PEDS_COUNT] = spawnPedOnPlayer(util.joaat(UNIVERSAL_PEDS_LIST[i]), players.user())
        wait()
    end)
end

SPAWNED_OBJECTS = {}
SPAWNED_OBJECTS_COUNT = 0
local spawnObjs = menu.list(spawnerList, "Spawn Objects", {}, "")
menu.action(spawnObjs, "Cleanup all spawned objects", {}, "", function ()
    if SPAWNED_OBJECTS_COUNT ~= 0 then
        for i = 1, SPAWNED_OBJECTS_COUNT do
            entities.delete_by_handle(SPAWNED_OBJECTS[i])
        end
        SPAWNED_OBJECTS_COUNT = 0
    else
        util.toast("No objects left!")
    end
end)
for i = 1, #UNIVERSAL_OBJECTS_LIST do
    menu.action(spawnObjs, "Spawn " .. tostring(UNIVERSAL_OBJECTS_LIST[i]), {"catspawnobj " .. tostring(UNIVERSAL_OBJECTS_LIST[i])}, "", function ()
        -- spawnObjectOnPlayer(util.joaat(UNIVERSAL_PEDS_LIST[i]), players.user())
        SPAWNED_OBJECTS_COUNT = SPAWNED_OBJECTS_COUNT + 1 --did it this way bc other way errored
        SPAWNED_OBJECTS[SPAWNED_OBJECTS_COUNT] = spawnObjectOnPlayer(util.joaat(tostring(UNIVERSAL_OBJECTS_LIST[i])), players.user())
        wait()
    end)
end

players.on_join(playerSetup)
players.dispatch_on_join()