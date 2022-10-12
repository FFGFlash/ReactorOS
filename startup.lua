os.pullEvent = os.pullEventRaw
term.clear()
term.setCursorPos(1,1)

local Network = require("/reactor/network")
local Events = require("/reactor/event_handler")()
local ReactorIds = Network:lookup()
local Reactors = {}
local Running = true
local Reactor = 1
local SelectedReactorId = -1
local SelectedReactor = {}
local next = next

Events:connect("terminate", function() Running = false end)
Events:connect("rednet_message", function(sender, req, protocol)
  if protocol ~= Network.Protocol then return end
  local event = table.remove(req, 1)

  if event == "update" then
    Reactors[sender] = table.remove(req, 1)
  end
end)

Events:connect("mouse_click", function(btn, x, y)
  if btn ~= 1 then return end
  local width, height = term.getSize()
  if x >= 1 and x <= 2 and y == 1 then
    Reactor = Reactor - 1
  elseif x >= width - 1 and x <= width and y == 1 then
    Reactor = Reactor + 1
  elseif y == height then
    Network:send(SelectedReactorId, SelectedReactor.Active and "reactor_stop" or "reactor_start")
  end
end)

Events:setInterval(function()
  ReactorIds = Network:lookup()
end, 0.05)

function Update()
  Reactor = math.min(math.max(Reactor, 1), #ReactorIds) or 1
  SelectedReactorId = ReactorIds[Reactor] or -1
  SelectedReactor = Reactors[SelectedReactorId] or {}
end

function Draw()
  local width, height = term.getSize()
  term.setBackgroundColor(colors.lightGray)
  term.clear()
  term.setCursorPos(1,1)
  if #ReactorIds == 0 then
    term.write("No Reactors Online...")
    return
  elseif next(Reactors) == nil then
    term.write("Awaiting Reactor Data...")
    return
  elseif next(SelectedReactor) == nil then
    term.write("Awaiting Reactor Data...")
    return
  end

  local color = SelectedReactor.Active and colors.lightBlue or colors.red

  local function writeCentered(text)
    local len = string.len(text)
    local x, y = term.getCursorPos()
    term.setCursorPos(x - len / 2, y)
    term.write(text)
  end

  local function writeNextLine(text)
    local x, y = term.getCursorPos()
    term.write(text)
    term.setCursorPos(x, y + 1)
  end

  term.setBackgroundColor(color)
  term.setTextColor(colors.black)
  term.clearLine()
  if Reactor > 1 then
    term.setCursorPos(2,1)
    term.write("<")
  end
  if Reactor < #ReactorIds then
    term.setCursorPos(width - 1, 1)
    term.write(">")
  end
  term.setCursorPos(width / 2, 1)
  writeCentered(SelectedReactor.Name)
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(colors.white)
  term.setCursorPos(2,3)
  writeNextLine("Control Rods: "..SelectedReactor.NumberOfControlRods)
  writeNextLine("Energy Produced: "..SelectedReactor.Energy.ProducedLastTick)
  writeNextLine("Energy (%): "..(math.floor(SelectedReactor.Energy.Stored / SelectedReactor.Energy.Capacity * 10000) / 100).."%")
  writeNextLine("Fuel Consumed: "..SelectedReactor.Fuel.ConsumedLastTick)
  writeNextLine("Fuel (%): "..(math.floor(SelectedReactor.Fuel.Amount / SelectedReactor.Fuel.Capacity * 10000) / 100).."%")
  writeNextLine("Waste (%): "..(math.floor(SelectedReactor.Fuel.Waste / SelectedReactor.Fuel.Capacity * 10000) / 100).."%")

  term.setCursorPos(width / 2, height)
  term.setBackgroundColor(color)
  term.setTextColor(colors.black)
  term.clearLine()

  writeCentered(SelectedReactor.Active and "Power Off" or "Power On")
end

while Running do
  Update()
  Draw()
  Events()
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
