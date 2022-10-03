local Network = { Hostname = nil, Protocol = "Reactor://", RequestTimeout = 15 }
Network.__index = Network

-- Open Rednet Channels Automatically
local ComputerId = os.getComputerID()
local Modems = { peripheral.find("modem") }
for i, modem in ipairs(Modems) do
  if modem.isWireless() then
    if not modem.isOpen(ComputerId) then modem.open(ComputerId) end
    if not modem.isOpen(65535) then modem.open(65535) end
    break
  end
end

function Network:__call(hostname)
  if not hostname then return true end
  local id = rednet.lookup(self.Protocol, hostname)
  if id then return false end
  rednet.host(self.Protocol, hostname)
  self.Hostname = hostname
  return true
end

function Network:lookup(hostname)
  return { rednet.lookup(self.Protocol, hostname) }
end

function Network:broadcast(event, ...)
  rednet.broadcast({ event, ... }, self.Protocol)
end

function Network:send(receiver, event, ...)
  rednet.send(receiver, { event, ... }, self.Protocol)
end

function Network:request(receiver, event, ...)
  rednet.send(receiver, { event, ... }, self.Protocol)
  local id, res = -1, nil
  repeat id, res = rednet.receive(self.Protocol, self.RequestTimeout)
  until id == receiver or id == nil
  return res
end

return setmetatable(Network, Network)
