local http = require('http.client').new()
local json = require('json')
local log = require('log')

local SERVER = arg[1]

local long_key = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' .. 
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' ..
'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

local function request(method, key, body, header)
  if header == nil then
    header = { ["Content-Type"] = "application/json" }
  end
  local resp = http:request(method, SERVER .. '/kv/' .. key, body, { headers = header })
  --    log.error(resp.status .. ' ' )
  --    if resp.body then log.error(resp.body) end
  return resp
end

local function testFailed(msg)
  log.error(debug.getinfo(2).currentline .. ' Test failed with msg ' .. msg)
  os.exit(1)
end

local function checkPOST()
  local js = nil
  local js_text = nil
  local resp = request('POST', 'testKey', nil)
  if resp.status ~= 405 then
    testFailed(resp.status .. ' ' .. resp.body)
  end
  js_text = ''
  resp = request('POST', '', js_text)
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end
  js = {["key"] = "key", ["value"] = true }
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  --[[
  -- json module can not validate json properly
  js = {["key"] = "key", ["key"] = "key", ["value"] = {["a"] = 1} }
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 201 then
    testFailed('Wrong json schema ' .. resp.status .. ' ' .. resp.body)
  end

  js = {["key"] = "key", ["key"] = "key", ["value"] = {["a"] = 1} , ["value"] = {["a"] = 1}}
  js_text = '{"key": "key", "key": "1", "value": {"a": 3} , "value": {"a": 1}}'
  resp = request('POST', '', js_text)
  if resp.status ~= 403 then
    testFailed('Wrong json schema ' .. resp.status .. ' ' .. resp.body)
  end
  --]]

  js = {["joke"] = "key", ["value"] = {["a"] = 1}}
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  js = {["key"] = "key", ["joke"] = {["a"] = 1}}
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end


  js = {["key"] = long_key, ["value"] = {["a"] = 1}}
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  js = {["key"] = "#%^&*()", ["value"] = {["a"] = 1}}
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end


  js = {["key"] = "key", ["value"] = {["a"] = 1} }
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 201 then
    testFailed(resp.status .. ' ' .. resp.body)
  end
  js = {["key"] = "key", ["value"] = {["a"] = 1} }
  js_text = json.encode(js)
  resp = request('POST', '', js_text)
  if resp.status ~= 409 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  resp = request('DELETE', 'key', nil)
  if resp.status ~= 200 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

end

local function checkPOST_PUT_GET_DELETE()
  local js = {["key"] = "POST_PUT_GET_DELETE", ["value"] = {["a"] = 1} }
  local js_text = json.encode(js)
  local js_orig = json.encode(js)
  local resp
  resp = request('POST', '', js_text)
  if resp.status ~= 201 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  js = json.decode(resp.body)
  js = json.encode(js.data)
  if js ~= js_orig then
    testFailed(js)
  end

  js = {["value"] = {["a"] = 1} }
  js_text = json.encode(js)
  resp = request('PUT', 'POST_PUT_GET_DELETE', js_text)
  if resp.status ~= 200 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  js = json.decode(resp.body)
  js = json.encode(js.data)
  if js ~= js_orig then
    testFailed(js)
  end

  resp = request('GET', 'POST_PUT_GET_DELETE', '')
  if resp.status ~= 200 then
    testFailed(resp.status)
  end
  js = json.decode(resp.body)
  js = json.encode(js.data)
  if js ~= js_orig then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  resp = request('DELETE', 'POST_PUT_GET_DELETE', nil)
  if resp.status ~= 200 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  js = json.decode(resp.body)
  js = json.encode(js.data)
  if js ~= js_orig then
    testFailed(js)
  end

end

local function checkDELETE()
  local js = {["key"] = "delete", ["value"] = {["a"] = 1} }
  local js_text = json.encode(js)
  local resp
  resp = request('POST', '', js_text)
  if resp.status ~= 201 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  resp = request('DELETE', 'delete', nil)
  if resp.status ~= 200 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  resp = request('DELETE', 'delete', nil)
  if resp.status ~= 404 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  resp = request('DELETE', '', nil)
  if resp.status ~= 405 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

end

local function checkPUT()
  local js = {["key"] = "blabla", ["value"] = {["a"] = 1} }
  local js_text = json.encode(js)
  local resp
  resp = request('PUT', 'PUT', js_text)
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  resp = request('PUT', '', js_text)
  if resp.status ~= 405 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

end

local function checkGET()
  local js = {["key"] = "blabla", ["value"] = {["a"] = 1} }
  local js_text = json.encode(js)
  local resp
  resp = request('POST', '', '32423')
  if resp.status ~= 400 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

  resp = request('GET', '23', '')
  if resp.status ~= 404 then
    testFailed(resp.status .. ' ' .. resp.body)
  end

end


log.info('Start')

checkPOST()
checkPOST_PUT_GET_DELETE()
checkDELETE()
checkPUT()
checkGET()
log.info('All test passed')
