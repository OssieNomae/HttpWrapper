--[[
	License: Licensed under the MIT License
	Version: 1.0.0
	Github: Link ???
	Authors:
		OssieNomae - 2024
		
	Dependencies:
		Lua-Promise: https://github.com/evaera/roblox-lua-promise

	HttpWrapper: Easy to use HttpWrapper around Roblox' already existing HTTPService API
	
	--------------------------------
	
	Functions:
		Module.HttpRequest(RequestOptions) -> Returns a HttpResponse (https://create.roblox.com/docs/reference/engine/classes/HttpService#RequestAsync)
		
		Module.AddURLParams(Url, Parameters) -> Returns the Url with URLSearchParams added onto (https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)
		
	--------------------------------
	
	-- Simple Get Request
	local Response = HttpWrapper.HttpRequest({
		Url = "https://httpbin.org/get",
		Method = "GET"
	})
	
	print(Response)
	
	-- Post Request with Url Params
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
		Body = HttpService:JSONEncode({
			Hello = "Put"
		})
	})
	
	if not Response.Success then return end
	
	local Result = HttpService:JSONDecode(Response.Body)
	print(Result)
	
--]]
--!strict

----- Module / Class / Object Table -----------
local Module = {}

----- Loaded Services -----
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Util / Shared / Modules  -----
local Promise = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Promise")) -- Promise Module

----- Types -----
export type HttpMethods = "POST" | "GET" | "PUT" | "PATCH" | "DELETE"

export type RequestOptions = {
	Url: string,
	Method: HttpMethods,
	Headers: {
		[string]: any,
	}?,
	Body: string?
}

export type HttpResponse = {
	Body: string?,
	Success: boolean,
	StatusCode: number,
	StatusMessage: string,
}

export type Parameters = {[string]: string}?

----- Private Methods -----
local function RequestASync(RequestOptions: RequestOptions)
	return Promise.new(function(Resolve, Reject, OnCancel)
		local Response = HttpService:RequestAsync({
			Url = RequestOptions.Url,
			Method = RequestOptions.Method,
			Headers = RequestOptions.Headers,
			Body = RequestOptions.Body
		})

		if not Response.Success then
			Reject(Response)
		end

		Resolve(Response)
	end)
end

----- Public Methods -----
function Module.AddURLParams(Url, Parameters: Parameters): string -- URLSearchParams
	if not Parameters then
		return Url
	end

	if string.find(Url, "?") == nil then
		Url ..= "?"
	end

	local Params = {}
	for Index,Value in pairs(Parameters) do -- Create a Array of Stringified Params
		table.insert(Params, `{tostring(Index)}={HttpService:UrlEncode(tostring(Value))}`)
	end

	Url ..= table.concat(Params, "&")

	return Url
end

function Module.HttpRequest(RequestOptions: RequestOptions): HttpResponse
	assert(type(RequestOptions.Url) == "string", `RequestOption "Url" argument missing!`)
	assert(type(RequestOptions.Method) == "string", `RequestOption "Method" argument missing!`)

	local Success: boolean, Response: HttpResponse = RequestASync(RequestOptions):await()

	if not Success then
		return {
			Success = false,
			StatusCode = 500,
			StatusMessage = "HttpRequest: ExecutionError",
			Body = tostring(Response)
		}
	end

	return Response
end

return Module