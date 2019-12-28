Key-value REST server
============

REST server based on tarantool database

# How to run ###

```
docker-compose up
```

# API

Path | Method | Body
--- | --- | --- 
/kv | POST | ```{"key": "string", "value": {json object}}```
/kv/{key} | PUT | ```{"value": {json object}}``` 
/kv/{key} | GET |
/kv/{key} | DELETE | 

Valid key symbols
```ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._[]@!$&()+=```

Maximum key lenght 512

## Response

Code | Reason
--- | --- 
200 | Success
201 | Success, record created
400 | Incorrect responce body
404 | Key does not exist
405 | Method not allowed
409 | Key already exists
429 | Response per second exceeded

### Body format

```
{
  "success": true/false,
  "message": "string with description",
  "data": { json object } 
}
```


Success | Data
--- | --- 
true | ```{"key": "string", "value": {json object}}```
false | ```{"key": "string"}``` or ```{}```

