--- load mission scripts for CSG-1 Server
--- requires script and mission files to be located in C:\CSGMission\GM Scripts\CSG Server Miz\Scripts
--- this is the only script directly called from the mission editor. It should be set to After Start

    function loadSource()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/MOOSE/Moose.lua"))()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/MIST/mist_4_5_122.lua"))()
    end

    function loadDMLmodules()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/DML Modules/dcsCommon.lua"))()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/DML Modules/cfxZones.lua"))()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/DML Modules/cfxMX.lua"))()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/DML Modules/stopGaps.lua"))()
    end

    function loadMissionAirInterceptTrainer()
        assert(loadfile("C:/CSGMission/GM Scripts/AirInterceptTrainer.lua"))()
    end

    function loadAirboss()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/TRAirboss.lua"))()
    end

    function loadAtoAdispatcher()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/TRA2ADispatcher.lua"))()
    end

    function loadFaralonRange()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/FDeMRange.lua"))()
    end

    function loadRAT()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/RATrevertedAndFixed.lua"))()
    end

    function loadSINKEX()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/SINKEX.lua"))()
    end

    function loadDynamicDeck()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/Dynamic Deck/dynamicDeck.lua"))()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/Dynamic Deck/dynamicDeckTemplates.lua"))()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/Dynamic Deck/dynamicDeckData.lua"))()
    end

    function loadMapAdmin()
        assert(loadfile("C:/CSGMission/GM Scripts/CSG Server Miz/Scripts/mapAdmin.lua"))()
    end

    function main()
        timer.scheduleFunction(loadSource, {}, timer.getTime() + 0.5)
        timer.scheduleFunction(loadDMLmodules, {}, timer.getTime() + 5)
        timer.scheduleFunction(loadMissionAirInterceptTrainer, {}, timer.getTime() + 10)
        timer.scheduleFunction(loadAirboss, {}, timer.getTime() + 15)
        timer.scheduleFunction(loadAtoAdispatcher, {}, timer.getTime() + 20)
        timer.scheduleFunction(loadFaralonRange, {}, timer.getTime() + 25)
        timer.scheduleFunction(loadRAT, {}, timer.getTime() + 30)
        timer.scheduleFunction(loadSINKEX, {}, timer.getTime() + 35)
        timer.scheduleFunction(loadDynamicDeck, {}, timer.getTime() + 40)
        timer.scheduleFunction(loadMapAdmin, {}, timer.getTime() + 45)
        return 0
    end

    main()
