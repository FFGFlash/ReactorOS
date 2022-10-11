os.pullEvent = os.pullEventRaw
term.clear()
term.setCursorPos(1,1)

local Network = require("/reactor/network")
local Events = require("/reactor/event_handler")()
local ReactorIds = Network:lookup()
local Reactors = {}
local Running = true
local Reactor = 1
local SelectedReactor = {}

Events:connect("terminate", function() Running = false end)
Events:connect("rednet_message", function(sender, req, protocol)
  if protocol ~= Network.Protocol then return end
  local event = table.remove(req, 1)

  if event == "update" then
    Reactors[sender] = table.remove(req, 1)
  end
end)

Events:setInterval(function()
  ReactorIds = Network:lookup()
end, 0.05)

function Update()
  Reactor = math.min(math.max(Reactor, 1), #ReactorIds) or 1
  SelectedReactor = Reactors[ReactorIds[Reactor]] or {}
end

function Draw()
  local width, height = term.getSize()
  term.setBackgroundColor(colors.lightGray)
  term.clear()
  term.setCursorPos(1,1)
  print(Reactors)
  -- if #ReactorIds == 0 then
  --   term.write("No Reactors Online...")
  --   return
  -- elseif Reactors == {} then
  --   term.write("Awaiting Reactor Data...")
  --   return
  -- elseif not SelectedReactor then
  --   term.write("Awaiting Reactor Data...")
  --   return
  -- end
  --
  -- local function writeCentered(text)
  --   local len = string.len(text)
  --   local x, y = term.getCursorPos()
  --   term.setCursorPos(x - len / 2, y)
  --   term.write(text)
  -- end
  --
  -- term.setBackgroundColor(colors.lightBlue)
  -- term.setTextColor(colors.black)
  -- term.clearLine()
  -- term.setCursorPos(width / 2, 1)
  -- writeCentered(SelectedReactor.Name)
  -- term.setBackgroundColor(colors.black)
  -- term.setTextColor(colors.white)
  -- term.setCursorPos(2,3)
  -- print("Control Rods: "..SelectedReactor.NumberOfControlRods)
  -- print("Energy Produced: "..SelectedReactor.Energy.ProducedLastTick)
  -- print("Energy (%): "..(math.floor(SelectedReactor.Energy.Stored / SelectedReactor.Energy.Capacity * 100)).."%")
  -- print("Fuel Consumed: "..SelectedReactor.Fuel.ConsumedLastTick)
  -- print("Fuel (%): "..(math.floor(SelectedReactor.Fuel.Amount / SelectedReactor.Fuel.Capacity * 100)).."%")
  -- print("Waste (%): "..(math.floor(SelectedReactor.Fuel.Waste / SelectedReactor.Fuel.Capacity * 100)).."%")
end

while Running do
  Update()
  Draw()
  Events()
end
