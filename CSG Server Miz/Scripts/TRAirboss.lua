	BASE:TraceOnOff(true)
	BASE:TraceLevel(1)
	BASE:TraceClass("AIRBOSS")

	gRecoveryTankerTable = {}
	gAwacsTable = {}

	-- No MOOSE settings menu. Comment out this line if required.
	_SETTINGS:SetPlayerMenuOff()

	-- Create AIRBOSS object.
	AirbossRoosevelt=AIRBOSS:New("USS Theodore Roosevelt")

	-- S-3B Recovery Tanker spawning on deck
	local tankerLow =RECOVERYTANKER:New("USS Theodore Roosevelt", "Texaco Group")
	--tanker:SetTakeoffAir()
	tankerLow:SetRadio(344.025)
	tankerLow:SetModex(700)
	tankerLow:SetTACAN(103, "TK")
	tankerLow:__Start(1)

	-- S-3B Recovery Tanker spawning on deck
	local tankerHigh =RECOVERYTANKER:New("USS Theodore Roosevelt", "Texaco Group-2")
	--tanker:SetTakeoffAir()
	tankerHigh:SetRadio(367.575)
	tankerHigh:SetModex(703)
	tankerHigh:SetTACAN(101,"TR")
	tankerHigh:SetAltitude(11000)
	tankerHigh:__Start(1)

	-- E-2D AWACS spawning on Roosevelt.
	local awacs=RECOVERYTANKER:New("USS Theodore Roosevelt", "E-2D Wizard Group")
	awacs:SetAWACS()
	awacs:SetRadio(317.775)
	awacs:SetAltitude(20000)
	awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
	awacs:SetRacetrackDistances(30, 15)
	awacs:SetModex(700)
	awacs:SetTACAN(65, "WIZ")
	awacs:__Start(1)


	-- Rescue Helo with home base on Roosevelt
	rescuehelo=RESCUEHELO:New("USS Theodore Roosevelt", "Rescue Helo")
	rescuehelo:SetHomeBase(AIRBASE:FindByName("USS Theodore Roosevelt"))
	rescuehelo:SetModex(42)
	rescuehelo:__Start(1)

	-- Single carrier menu optimization.
	AirbossRoosevelt:SetMenuSingleCarrier()

	-- Skipper menu.
	AirbossRoosevelt:SetMenuRecovery(90, 25, false, 0)

	-- Remove landed AI planes from flight deck.
	AirbossRoosevelt:SetDespawnOnEngineShutdown()

	-- Set TACAN and Radio freqs
	AirbossRoosevelt:SetTACAN(71, "X", "TRO")--]]
	AirbossRoosevelt:SetLSORadio(308.475)
	AirbossRoosevelt:SetMarshalRadio(285.675)
	AirbossRoosevelt:SetPatrolAdInfinitum(true)


	-- Start airboss class
	AirbossRoosevelt:Start()
	AirbossRoosevelt:DeleteAllRecoveryWindows(2)	-- sanitise recovery window table

	--- Function called when recovery tanker is started.
	function tankerLow:OnAfterStart(From, Event, To)

		--Set recovery tanker.
		AirbossRoosevelt:SetRecoveryTanker(tankerLow)


		-- Use tanker as radio relay unit for LSO transmissions.
		AirbossRoosevelt:SetRadioRelayLSO(self:GetUnitName())

	end

	--- Function called when AWACS is started.
	function awacs:OnAfterStart(From,Event,To)
		-- Set AWACS.
		AirbossRoosevelt:SetRecoveryTanker(tankerLow)
		--UNIT:FindByName(awacs:GetUnitName()):CommandEPLRS(false, 5)
		--awacs.eplrs = false
	end

	--- Function called when rescue helo is started.
	function rescuehelo:OnAfterStart(From,Event,To)
		-- Use rescue helo as radio relay for Marshal.
		AirbossRoosevelt:SetRadioRelayMarshal(self:GetUnitName())
	end

	function steamIntoWind(recoveryPeriod)
		AirbossRoosevelt:CarrierTurnIntoWind(recoveryPeriod, 25, false)
	end

	function beginRecoveryHelper(recoveryPeriod)
		BASE:E("beginRecoveryHelper fn")
		local currentTime = timer.getAbsTime()
		local recoveryStartSeconds = currentTime + 10
		AirbossRoosevelt:AddRecoveryWindow(UTILS.SecondsToClock(recoveryStartSeconds, true), UTILS.SecondsToClock(recoveryStartSeconds + recoveryPeriod, true), 1, nil, false, 20, false)
		AirbossRoosevelt:_CheckRecoveryTimes()
		steamIntoWind(recoveryPeriod)
	end

	function recoveryTimeHelper(hmsTime)	-- not used in current implementation, removes ":ss" from time formatted "hh:mm:ss"
		BASE:E("recoveryTimeHelper fn")
		local hmTime = string.sub(hmsTime, 1, #hmsTime - 3)
		MESSAGE:New(hmTime .. " " .. #hmsTime):ToAll()
		return hmTime
	end

	function endRecovery(delay)
		AirbossRoosevelt:RecoveryStop(delay)
	end

	local function eplrsOnOff(lUnit, eplrsSwitch)
		return lUnit:CommandEPLRS(eplrsSwitch)
	end

	local function newSpawnGroup(lGroupTemplate)
		local newSpawn = SPAWN:New(lGroupTemplate)
		return awacsGroup
	end

	-- avoids use of airboss to initialise AWACS and enable manual settng of EPLRS
	local function spawnNewGroup(spawnInst)
		return spawnInst:SPAWN()
	end

	local function setCarrierLights()

	end

	-- Menu for on-demand recovery windows
	--recoveryWindowMenu = MENU_COALITION:New(coalition.side.BLUE, "Recovery Window")	-- top level menu (under F10)
	--closeRecoveryWindow = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Close Current Recovery Window", recoveryWindowMenu, endRecovery, 10)
	--fifteenMinuteWindow = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Initiate 15 Minute Recovery Window", recoveryWindowMenu, beginRecoveryHelper, 900)
	--thirtyMinuteWindow = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Initiate 30 Minute Recovery Window", recoveryWindowMenu, beginRecoveryHelper, 1800)
	--fortyfiveMinuteWindow = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Initiate 45 Minute Recovery Window", recoveryWindowMenu, beginRecoveryHelper, 2700)
	--sixtyMinuteWindow = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Initiate 60 Minute Recovery Window", recoveryWindowMenu, beginRecoveryHelper, 3600)
	--ninetyMinuteWindow = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Initiate 90 Minute Recovery Window", recoveryWindowMenu, beginRecoveryHelper, 5400)

	function main()
		--AirbossRoosevelt.SetTrapSheet()
		MESSAGE:New("Roosevelt Airboss Loaded"):ToAll()
		return 0
	end

	main()


	