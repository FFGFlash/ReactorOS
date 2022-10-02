os.pullEvent = os.pullEventRaw

local Network = require("/reactor/network")
local Events = require("/reactor/event_handler")()
local Reactor = require("/reactor/reactor")
local Settings = require("/reactor/settings")(nil, {
  ["reactor.name"] = { description = "The display name for the reactor.", type = "string" }
})
local Name = Settings:get("reactor.name")
local Running = true

while true do
  if not Name then
    term.clear()
    term.setCursorPos(1,1)
    term.write("Reactor Name? ")
    Name = read()
  end
  if Network(Name) then
    Settings:set("reactor.name", Name)
    break
  else
    Name = nil
    print("Name Already in Use")
    sleep(5)
  end
end

Events:connect("terminate", function() Running = false end)
Events:connect("rednet_message", function(sender, req, protocol)
  if protocol ~= Network.Protocol then return end
  local event = table.remove(req, 1)

  if event == "name_request" then
    Network:send(sender, "name_response", Name)
  elseif event == "reactor_start" then
    Reactor:start()
  elseif event == "reactor_stop" then
    Reactor:stop()
  elseif event == "reactor_set_levels" then
    Reactor:setLevels(table.unpack(req))
  elseif event == "reactor_set_level" then
    Reactor:setLevel(table.unpack(req))
  end
end)

function Draw()
  local function writeInfo(header, text)
    local x1, y1 = term.getCursorPos()
    term.setBackgroundColor(colors.lightBlue)
    term.setTextColor(colors.black)
    term.write(header)
    local x, y = term.getCursorPos()
    term.setCursorPos(x1, y1 + 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    tern.write(text)
    local X, Y = term.getCursorPos()
    local x2, y2 = math.max(x, X), math.max(y, Y)
    term.setCursorPos(x2, y1)
    return { x1, y1, x2 + 1, y2 + 1 }
  end

  term.clear()
  term.setCursorPos(1,1)
  term.setBackgroundColor(colors.lightBlue)
  term.clearLine()
  local bb = writeInfo("Produced", Reactor.Energy.ProducedLastTick)
  writeInfo("Stored /", Reactor.Energy.Stored)
  writeInfo("Capacity", Reactor.Energy.Capacity)
  term.setCursorPos(bb[1], bb[4])
  term.setBackgroundColor(colors.lightBlue)
  term.clearLine()
  writeInfo("Consumed", Reactor.Fuel.ConsumedLastTick)
  writeInfo("Stored +", Reactor.Fuel.Amount)
  writeInfo("Waste /", Reactor.Fuel.Waste)
  writeInfo("Capacity", Reactor.Fuel.Capacity)
end

while Running do
  Network:broadcast("update", Reactor())
  Draw()
  Events()
end

term.clear()
term.setCursorPos(1,1)
