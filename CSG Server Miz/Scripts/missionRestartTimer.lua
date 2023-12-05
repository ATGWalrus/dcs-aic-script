--- Displays messages warning server will restart
--- currently unused
    local missionStarted = TIMER:New(MESSAGE:New("Mission Initialised"):ToAll()):Start(65)
    local countdownThirty = TIMER:New(MESSAGE:New("30 minutes until server restart"):ToAll()):Start(19800)
    local countdownFifteen = TIMER:New(MESSAGE:New("15 minutes until server restart"):ToAll()):Start(20700)
    local countdownTen = TIMER:New(MESSAGE:New("10 minutes until server restart"):ToAll()):Start(21000)
    local countdownFive = TIMER:New(MESSAGE:New("5 minutes until server restart"):ToAll()):Start(21300)
    local countdownTwo = TIMER:New(MESSAGE:New("2 minutes until server restart"):ToAll()):Start(21480)
    local countdownOne = TIMER:New(MESSAGE:New("1 minute until server restart"):ToAll()):Start(21540)