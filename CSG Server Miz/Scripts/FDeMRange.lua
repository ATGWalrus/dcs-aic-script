---
--- shamelessly copied from shagrat's On the Range mission

    -- Bomb Range Faralon de Medinilla
    local bombCirclesFDM = {"CircleA", "CircleB", "CircleC", "CircleD"}
    local StrafeSouth = {"Strafe1", "Strafe2", "Strafe3"}
    RangeFDM = RANGE:New("R-7201 (FDM)")
    RangeFDM:SetRangeZone(ZONE:New("ZoneRangeFDM"))
    RangeFDM:SetScoreBombDistance(200)
    RangeFDM:AddBombingTargets( bombCirclesFDM, 30)
    RangeFDM:AddStrafePit(StrafeSouth, 5000, 1000, nil, false, 20, 305)
    RangeFDM:SetDefaultPlayerSmokeBomb(false)
    RangeFDM:SetRangeControl(260)
    RangeFDM:SetInstructorRadio(270)
    RangeFDM:Start()
    MESSAGE:New("Faralon Range Script Loaded"):ToAll()