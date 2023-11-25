--[[
1. Qty
2. Adding EWR to sam spawns for IADS
3. Adding category in menu for additional types of spawns in Killboxes (Patrol, Buildings, etc.)
]]--

env.info("killbox loading", false)

--- MENU STRUCTURE
--
-- ACTIVATE KILLBOX (menu root)
--   |_KILLBOX ZONE (menu level 1)
--     |_THREAT TYPE (command level 2)
--   |_DEACTIVATE ALL ZONES (command level 1)
-- 
-- A menu for each killbox zone is added to the Killbox Threat root menu.
-- Menus for spawning each threat type are added to each of the killbox zone 
-- menus.
--
-- When a threat is selected, it will be spawned in the chosen killbox zone.
-- The threat selection menus are removed from the killbox zone menu and 
-- replaced with menus to either respawn a fresh copy of the chosen threat, 
-- or to remove the threat and deactivate the killbox.
-- 
-- A list of killboxes containing active threats is maintained. This list is 
-- stepped through to obtain the details for each spawned threat if the menu 
-- option to deactivate all zones is selected.


---------------------------------------------------------------------------------------------------
--- KILLBOX TABLE
---------------------------------------------------------------------------------------------------

--- KILLBOX table initialisation
-- @table KILLBOX
local KILLBOX = {}

--- Root menu.
-- @field #table menuTop Root KILLTABLE top level menu
--MenuTop = MENU_COALITION:New(coalition.side.BLUE, "Killbox Menus")
SEAD = MENU_COALITION:New(coalition.side.BLUE, "A/G Ranges")
KILLBOX.menuTop = MENU_COALITION:New(coalition.side.BLUE, "SAM Ranges", SEAD)
--- Killbox selection menu.
-- @field #table menuZones 
KILLBOX.menuZones = {}
--- List of active killboxes.
-- @field #table activeSites List of sites with an active threat
KILLBOX.activeSites = {}

--- ZONES
-- @field #table zones
-- @field #string zoneName Name of ZONE object in ME representing the killbox. Can be either a ZONE or a ZONE_POLYGON
-- @field #string kbName Lable for killbox. MUST be UNIQUE.
-- @field #string menuText Text to be used for the killbox's menu.
KILLBOX.zones = {
  { zoneName = "OIR 22 Range", kbName = "OIR22", menuText = "OIR 22 Range"},
  }

--- THREATS
-- @field #table threats each record represents a specific threat
-- @field #string spawnTemplate Name of template GROUP.
-- @field #string menuText Text to be used for the threat's menu.
-- @field #string threatText Text to display in threat's activation message.
KILLBOX.threats = {
  { spawnTemplate = "kbSAM-SA2",        menuText = "Activate SA-2", threatText = "SA-2" },
  { spawnTemplate = "kbSAM-SA3",        menuText = "Activate SA-3", threatText = "SA-3" }, 
  { spawnTemplate = "kbSAM-SA5",        menuText = "Activate SA-5", threatText = "SA-5" },
  { spawnTemplate = "kbSAM-SA6",        menuText = "Activate SA-6", threatText = "SA-6" },
  { spawnTemplate = "kbSAM-SA9",        menuText = "Activate SA-9", threatText = "SA-9"},
  { spawnTemplate = "kbSAM-SA10",       menuText = "Activate SA-10", threatText = "SA-10" },
  { spawnTemplate = "kbSAM-SA11",       menuText = "Activate SA-11", threatText = "SA-11" },
  { spawnTemplate = "kbSAM-Rapier",     menuText = "Activate Rapier", threatText = "Rapier" },
  { spawnTemplate = "kbSAM-Hawk",       menuText = "Activate Hawk", threatText = "Hawk" },
  }


---------------------------------------------------------------------------------------------------
--- ACTIVATE THREAT
-----------------------------------------------------------------------------------------------------

--- Activate threat in chosen zone.
-- @param #string spawnTemplate Name of group used as template for spawning threat. From KILLBOX.threats.
-- @param #tring kbName Name of the kill box. Used for killbox's record in list of active sites. From KILLBOX.zones.
-- @param #string zoneName Name of kill box zone from KILLBOX.zones.
-- @param #string threatText Text for threat to be used in activeation message. 
function activateKILLBOXThreat(spawnTemplate, kbName, zoneName, threatText)

  --debugMsg = MESSAGE:New(kbName .. "Activating Threat"):ToAll()

  -- remove threat submenus
  KILLBOX.menuZones[kbName]:RemoveSubMenus()
  --initialise entry in table of active zones 
  KILLBOX.activeSites[kbName] = {}
  
  -- KILLBOX zone is either a ZONE or a ZONE_POLYGON
  local kbSpawnZone = (ZONE:FindByName(zoneName) and ZONE:FindByName(zoneName) or ZONE_POLYGON:FindByName(zoneName))
  
  -- Alias to use for each threat SPAWN object so that spawned group names include the killbox label
  local spawnAliasPrefix = kbName .. "-" .. spawnTemplate
  
  -- spawn threat in KILLBOX zone
  KILLBOX.activeSites[kbName].spawn = SPAWN:NewWithAlias( spawnTemplate, spawnAliasPrefix)  --SPAWN:New(spawnTemplate)
  
   --debugMsg = MESSAGE:New(kbName .. "SPAWN object created"):ToAll()

  -- spawn threat in killbox
  -- add threat to killbox's entry in activeSites list
  -- activate IADS for threat
  KILLBOX.activeSites[kbName].spawn:OnSpawnGroup(
      function (spawnGroup)
        MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deactivate Killbox", KILLBOX.menuZones[kbName], resetKILLBOXThreat, spawnGroup, threatText, kbName, zoneName, kbSpawnZone, false)
        MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Reset Killbox", KILLBOX.menuZones[kbName], resetKILLBOXThreat, spawnGroup, threatText, kbName, zoneName, kbSpawnZone, true)
        KILLBOX.activeSites[kbName].activeThreat = {spawnGroup, threatText, kbName, zoneName, kbSpawnZone, false}
        MESSAGE:New("Killbox " .. kbName .. " is active with " .. threatText):ToAll()
        KILLBOX.activeSites[kbName].rIADS = SkynetIADS:create("KILLBOX" .. kbName)
        KILLBOX.activeSites[kbName].rIADS:setUpdateInterval(5)
        KILLBOX.activeSites[kbName].rIADS:addSAMSite(spawnGroup.GroupName)
        KILLBOX.activeSites[kbName].rIADS:getSAMSiteByGroupName(spawnGroup.GroupName):setGoLiveRangeInPercent(80)
        KILLBOX.activeSites[kbName].rIADS:activate()        
        --debugMsg = MESSAGE:New(kbName .. " - spawnGoup = " .. spawnGroup.GroupName):ToAll()
      end
      , threatText, kbName, zoneName, kbSpawnZone
    )
    
  -- spawn threat at random point wqithin killbox
  KILLBOX.activeSites[kbName].spawn:SpawnInZone(kbSpawnZone, true)

end


---------------------------------------------------------------------------------------------------
--- RESET THREAT
---------------------------------------------------------------------------------------------------

--- Reset selected threat, or deactivate killbox.
-- @param #table spawnGroup GROUP object for spawned threat.
-- @param #string threatText Text used in message when threat reset or removed. From KILLBOX.threats.
-- @param #string kbName Label of killbox. From KILLBOX.zones.
-- @param #string zoneName Name of ZONE or ZONE_POLYGON representing killbox. From KILLBOX.zones.
-- @param #table kbSpawnZone ZONE or ZONE_POLYGON object representing killbox.
-- @param #boolean refreshKILLBOX If ture previously chosen threat will be removed and respawned at a random location within the killbox.
function resetKILLBOXThreat(spawnGroup, threatText, kbName, zoneName, kbSpawnZone, refreshKILLBOX)

  --debugMsg = MESSAGE:New(kbName .. " Reset"):ToAll()

  -- remove deactivate and reset submenus from the killbox's zone menu.
  KILLBOX.menuZones[kbName]:RemoveSubMenus()
  
  -- deactivate IADS for threat if currently active.
  if KILLBOX.activeSites[kbName].rIADS ~= nil then
    KILLBOX.activeSites[kbName].rIADS:deactivate()
    KILLBOX.activeSites[kbName].rIADS = nil
  end

  -- remove the spawned threat if it is still alive.
  if spawnGroup:IsAlive() then
    spawnGroup:Destroy()
  end

  if refreshKILLBOX then
    -- debugMsg = MESSAGE:New(kbName .. "Refresh Threat"):ToAll()
    -- spawn a fresh group of the chosen threat at a random point in the killbox.
    KILLBOX.activeSites[kbName].spawn:SpawnInZone(kbSpawnZone, true)
  else
    -- add threat menus back to the killbox's zone menu
    addKILLBOXThreatMenu(kbName, zoneName)
    MESSAGE:New("killbox " .. kbName .. "  " .. threatText .." has been deactived."):ToAll()
  end    

end


---------------------------------------------------------------------------------------------------
--- DEACTIVATE ALL ZONES
---------------------------------------------------------------------------------------------------

--- Deactivate spawned threats in ALL killboxes
function resetKILLBOXAll()

  --debugMsg = MESSAGE:New("Reset All"):ToAll()
  
  -- step through KILLBOX.activeSites list and call resetKILLBOXThreat for any killboxes that are active.
  for kb, kbActive in pairs(KILLBOX.activeSites) do
    --debugMsg = MESSAGE:New("Resetting ".. kb):ToAll()
    resetKILLBOXThreat( kbActive.activeThreat[1], kbActive.activeThreat[2], kbActive.activeThreat[3], kbActive.activeThreat[4], kbActive.activeThreat[5], kbActive.activeThreat[6] )
  end
  
end


---------------------------------------------------------------------------------------------------
--- ADD ZONE MENUS
---------------------------------------------------------------------------------------------------

--- Add ZONE menus to Killbox Threat root menu
function addKILLBOXZoneMenu()

  -- step through KILLBOX.zones and add a zone menu for each killbox
  for i, kbZone in ipairs(KILLBOX.zones) do
    -- add the killbox's zone menu to the Killbox Threat menu
    KILLBOX.menuZones[kbZone.kbName] = MENU_COALITION:New( coalition.side.BLUE, kbZone.menuText, KILLBOX.menuTop )
    -- add threat menus to the killbox's zone menu
    addKILLBOXThreatMenu( kbZone.kbName, kbZone.zoneName )
  end
  
  -- deactivate ALL active zones
  MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Deactivate all Killboxes",KILLBOX.menuTop,resetKILLBOXAll)

end


---------------------------------------------------------------------------------------------------
--- ADD THREAT MENUS
---------------------------------------------------------------------------------------------------
  
--- Add THREAT menu commands to each zone for activating each threat type
function addKILLBOXThreatMenu(kbName, zoneName)

  for i, kbThreat in ipairs(KILLBOX.threats) do
    MENU_COALITION_COMMAND:New( coalition.side.BLUE, kbThreat.menuText, KILLBOX.menuZones[kbName], activateKILLBOXThreat, kbThreat.spawnTemplate, kbName, zoneName, kbThreat.threatText, false )
  end
  
end
 
addKILLBOXZoneMenu()


env.info("killbox complete", false)
