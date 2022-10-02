local Peripheral = peripheral.find("BigReactors-Reactor")

local Reactor = {
  NumberOfControlRods = 0,
  Active = false,
  Levels = 0,
  Energy = {},
  Fuel = {}
}
Reactor.__index = Reactor

function Reactor:__call()
  local energy = Peripheral.getEnergyStats()
  local fuel = Peripheral.getFuelStats()

  self.NumberOfControlRods = Peripheral.getNumberOfControlRods()
  self.Active = Peripheral.getActive()
  self.Levels = Peripheral.getControlRodsLevels()

  for name, value in pairs(energy) do
    self.Energy[strsub(name, 7)] = math.floor(value * 100) / 100
  end

  for name, value in pairs(fuel) do
    self.Fuel[strsub(name, 5)] = math.floor(value * 100) / 100
  end

  return self
end

function Reactor:start()
  Peripheral.setActive(true)
end

function Reactor:stop()
  Peripheral.setActive(false)
end

function Reactor:setLevel(id, level)
  Peripheral.setControlRodLevel(id, level)
end

function Reactor:setLevels(level)
  for i = 1, self.NumberOfControlRods, 1 do
    self:setLevel(i - 1, level)
  end
end

return setmetatable(Reactor, Reactor)
