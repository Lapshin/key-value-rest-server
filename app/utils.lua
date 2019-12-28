local json = require('json')
local log  = require('log')

local utils = {}

local path_prefix = "/kv/"

local success_codes = {
  ["GET"] = 200,
  ["POST"] = 201,
  ["PUT"] = 200,
  ["DELETE"] = 200,
}


-- code: http return code
-- method: http method which we responding
-- message: text message with response description
-- data: if success {"key", "json_value"}
--       if error "key"
function utils.buildResponseJson(code, method, message, data)
  local success = success_codes[method] == code
  local data_to_send = data
  local data_text = data
  if success then
    data_to_send = { ["key"] = data[1], ["value"] = data[2] }
    data_text = data[1]
  else
    data_to_send = { ["key"] = data }
  end

  local response = {
    ["success"] = success,
    ["message"] = message,
    ["data"] = data_to_send
  }

  local log_msg = string.format("%s: Key \"%s\". success (%s) message: %s. ", method, data_text , success, message)
  if success == true then
    log.info(log_msg)
  else
    log.error(log_msg)
  end

  return { ["code"] = code, ["result"] = response }
end

function decodeChar(hex)
  return string.char(tonumber(hex,16))
end

function decodeString(str)
  local output, t = string.gsub(str,"%%(%x%x)",decodeChar)
  return output
end

function utils.getKeyFromUri(uri)
  local len = string.len(path_prefix)
  local sub = string.sub(uri, 0, len)
  if sub == path_prefix then
    local key = string.sub(uri, len + 1, -1)
    return decodeString(key)
  else
    return nil
  end
end

function checkAllowedKeys(key, value, keys)
  for k, v in pairs(keys) do
    if key == k then
      if v[1] >= 1 then
        return false -- key has duplicate
      end
      if type(value) ~= keys[k][2] then
        return false --key type is wrong
      end
      keys[k][1] = v[1] + 1
      return true
    end

  end
  return false -- key is not found in allowed key table
end

function utils.validateJson(json_text, allowed_keys)
  local status, data = pcall(json.decode, json_text)
  if status == false or type(data) ~= "table" then
    return false, nil, 'Expected json in body'
  end
  for k, v in next, data do
    status = checkAllowedKeys(k, v, allowed_keys)
    if status == false then
      return false, nil, 'Received wrong json schema'
    end
  end
  for k, v in next, allowed_keys do
    if v[1] ~= 1 then
      return false, nil, 'Received wrong json schema'
    end
  end
  return true, data, 'ok'
end

function utils.matchPattern(str, pattern)
  local flag = false
  for c in string.gmatch(str, ".") do
    -- string.find does not work
    --[[
    log.error(string.find(c, pattern))
    if not string.find(c, pattern) then
      return false
    end
    --]]
    flag = false
    for p in string.gmatch(pattern, ".") do
      if c == p then
        flag = true
        break
      end
    end
    if flag == false then
      return false
    end
  end
  return true
end

return utils
