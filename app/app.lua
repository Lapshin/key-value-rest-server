local log = require('log')
local utils  = require("utils")

box.cfg {
  listen = "3301",
  log = "/var/run/tarantool/tarantool.log",
  pid_file = "/var/run/tarantool/tarantool.pid",
}

-- workaround. Need because docker-compose command changed to `sh -c ...`
box.once('init user', function()
box.schema.user.grant('guest', 'read,write,execute', 'universe')
end)


local space = box.schema.space.create('kv', {if_not_exists = true})
local db = space:create_index('primary', {
  unique = true,
  if_not_exists = true,
  parts = {1,'string'}
})

local pattern = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._[]@!$&()+="

function retrieve(request)
  local code = 200
  local message = 'read successfully'
  local key = utils.getKeyFromUri(request.uri)
  local data = db:get{key}
  if data == nil then
    code = 404
    message = 'Key not found'
    data = key
  end
  return utils.buildResponseJson(code, 'GET', message, data)
end

function create(request)
  local code = 0
  local message = ''
  local result = nil
  local data = nil
  local allowed_keys =  {
    ["key"] = { 0, "string" },
    ["value"] = { 0, "table" }
  }
  result, data, message = utils.validateJson(request.body, allowed_keys)
  if result == false then
    code = 400
    goto exit
  end

  if string.len(data.key) > 512 then
    code = 400
    message = 'Key is more then 512 characters'
    data = data.key
    goto exit
  end

  if utils.matchPattern(data.key, pattern) == false then
    code = 400
    message = string.format('Key can contain only symbols %s', pattern);
    data = data.key
    goto exit
  end
  status, result = pcall(function(t) return space:insert(t) end, { data.key, data.value })
  if status == false then
    message = 'Key already exists'
    code = 409
    data = data.key
  else
    message = 'Key/Value successfully added'
    code = 201
    data = result
  end
  ::exit::
  return utils.buildResponseJson(code, 'POST', message, data)
end

function update(request)
  local code = 0
  local message = ''
  local key = ''
  local result = nil
  local data = nil
  local allowed_keys =  {
    ["value"] = { 0, "table" }
  }
  key = utils.getKeyFromUri(request.uri)
  result, data, message = utils.validateJson(request.body, allowed_keys)
  if result == false then
    code = 400
    data = key
    goto exit
  end
  data = db:update(key, {{'=', 2, data.value}})
  if data == nil then
    message = 'Key not found'
    code = 404
    data = key
  else
    message = "Record successfully updated"
    code = 200
  end
  ::exit::
  return utils.buildResponseJson(code, 'PUT', message, data)
end

function delete(request)
  local code = 200
  local message = 'Deleted successfully'
  local key = utils.getKeyFromUri(request.uri)
  local data = db:delete{key}
  if data == nil then
    message = 'Key not found'
    code = 404
    data = key

  end
  return utils.buildResponseJson(code, 'DELETE', message, data)
end

