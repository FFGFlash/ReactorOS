return function(path, descriptor)
  if not path then path = ".settings" end
  settings.load(path)

  for name, options in pairs(descriptor) do settings.define(name, options) end

  local Handler = { Path = path }

  function Handler:save()
    settings.save(self.Path)
  end

  function Handler:set(name, value)
    settings.set(name, value)
    self:save()
  end

  function Handler:load()
    settings.load(self.Path)
  end

  return Handler
end
