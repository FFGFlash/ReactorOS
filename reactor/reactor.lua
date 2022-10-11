local Peripheral = peripheral.find("BigReactors-Reactor")

local Reactor = {
  Name = "",
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
    pcall(function() value = math.floor(tonumber(value) * 100) / 100 end)
    self.Energy[string.sub(name, 7)] = value
  end

  for name, value in pairs(fuel) do
    pcall(function() value = math.floor(tonumber(value) * 100) / 100 end)
    self.Fuel[string.sub(name, 5)] = value
  end

  self.Fuel.Waste = self.Fuel.eAmount
  self.Fuel.eAmount = nil

  return self
end

function Reactor:setName(name)
  self.Name = name
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
