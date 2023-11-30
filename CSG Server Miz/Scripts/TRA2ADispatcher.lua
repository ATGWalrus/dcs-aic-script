-- creates and initialises fleet air defence for the Roosevelt CVBG

local rooseveltDetectionGroup = SET_GROUP:New()
local rooseveltInterceptZone = ZONE_GROUP:New("interceptZone", UNIT:FindByName("USS Theodore Roosevelt"), 200000)	-- instantiates a ZONE_GROUP with r = 200km centred on TR CVBG

rooseveltDetectionGroup:FilterPrefixes({"E-2D Wizard Group", "USS Theodore Roosevelt"})
rooseveltDetectionGroup:FilterStart()

local detectionRoosevelt = DETECTION_AREAS:New(rooseveltDetectionGroup, 25000)	-- targets within 25km of one another will be treated as a single group by the dispatcher

-- Create A2A Dispatcher object
A2ADispatcherRoosevelt = AI_A2A_DISPATCHER:New(detectionRoosevelt)

-- Initialize the dispatcher using ZONE_GROUP centred on the Roosevelt carrier group 
-- Any enemy crossing this border will be engaged.
A2ADispatcherRoosevelt:SetBorderZone(rooseveltInterceptZone)

-- A2ADispatcher Settings
A2ADispatcherRoosevelt:SetDefaultGrouping(2)
A2ADispatcherRoosevelt:SetEngageRadius(200000)	-- hostile groups within engagement zone will be engaged by fighters within r = 200km

-- Define squadrons for GCI/CAP
A2ADispatcherRoosevelt:SetSquadron("VF-51", "USS Theodore Roosevelt", "VF-51-1", 11)
A2ADispatcherRoosevelt:SetSquadronTakeoffFromParkingHot("VF-51")

 -- Set Squadron GCI tasking
A2ADispatcherRoosevelt:SetSquadronGci("VF-51", 1100, 1800)

 -- Start Dispatcher
A2ADispatcherRoosevelt:Start()