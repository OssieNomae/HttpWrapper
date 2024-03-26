# HttpWrapper
HttpWrapper around Roblox's already existing HTTPService API
- Easy to use
- Promise based

## Methods
```lua
.AddURLParams(Url, Parameters) -> Returns the Url with URLSearchParams added onto
-- https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams

.PromiseHttpRequest(RequestOptions) -> Returns a HttpResponse Promise

.HttpRequest(RequestOptions) -> Returns a HttpResponse
-- https://create.roblox.com/docs/reference/engine/classes/HttpService#RequestAsync

.JSONEncode(Table) -> [String] -- This is just HTTPService:JSONEncode wrapped
		
.JSONDecode(String) -> [Table] -- This is just HTTPService:JSONDecode wrapped
```
## Examples usage
```lua
-- Simple Get Request
local Response = HttpWrapper.HttpRequest({
  Url = "https://httpbin.org/get",
  Method = "GET"
})

print(Response)
```
```lua
-- Put Request with Url Params
local Response = HttpWrapper.HttpRequest({
  Url = HttpWrapper.AddURLParams("https://httpbin.org/put", {
    Name = "Tobie",
    Data = "Some random data",
    Test = "StringVariable",
  }),
  Method = "PUT",
  Headers = {
    ["Content-Type"] = "application/json"
  },
  Body = HttpWrapper.JSONEncode({
    Hello = "Put"
  })
})

if not Response.Success then return end

local Result = HttpWrapper.JSONDecode(Response.Body)
print(Result)
```
