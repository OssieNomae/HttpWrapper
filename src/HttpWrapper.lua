--[[
	License: Licensed under the MIT License
	Version: 1.1.0
	Github: https://github.com/OssieNomae/HttpWrapper
	Authors:
		OssieNomae - 2024

	HttpWrapper: Easy to use HttpWrapper around Roblox' already existing HTTPService API
	
	--------------------------------
	
	Functions:
		Module.AddURLParams(Url, UrlParameters) -> Returns the Url with URLSearchParams added onto -- https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams
	
		Module.HttpRequest(RequestOptions) -> Returns a HttpResponse -- https://create.roblox.com/docs/reference/engine/classes/HttpService#RequestAsync
		
		Module.JSONEncode(Table) -> [String] -- This is just HTTPService:JSONEncode wrapped
		
		Module.JSONDecode(String) -> [Table] -- This is just HTTPService:JSONDecode wrapped
		
	--------------------------------
	
	-- Simple Get Request
	local Response = HttpWrapper.HttpRequest({
		Url = "https://httpbin.org/get",
		Method = "GET"
	})
	
	print(Response)
	
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
	
--]]
--!strict

----- Module / Class / Object Table -----------
local Module = {}

----- Loaded Services -----
local HttpService = game:GetService("HttpService")

----- Util / Shared / Modules  -----

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

export type UrlParameters = {[string]: string}?

----- Private Variables -----
local HttpMethodsDict = { -- for validation
	POST = true,
	GET = true,
	PUT = true,
	PATCH = true,
	DELETE = true
}

----- Private Methods -----
local function RequestASync(RequestOptions: RequestOptions): HttpResponse
	local ExecuteSuccess, Response: HttpResponse = pcall(function()
		return HttpService:RequestAsync({
			Url = RequestOptions.Url,
			Method = RequestOptions.Method,
			Headers = RequestOptions.Headers,
			Body = RequestOptions.Body
		})
	end)
	
	if not ExecuteSuccess then
		return {
			Success = false,
			StatusCode = 500,
			StatusMessage = "HttpRequest: ExecutionError",
			Body = tostring(Response)
		}
	end

	return Response
end

----- Public Methods -----
function Module.JSONEncode(Table: any): string
	return HttpService:JSONEncode(Table)
end

function Module.JSONDecode(String: string): any
	return HttpService:JSONDecode(String)
end

function Module.AddURLParams(Url, UrlParameters: UrlParameters): string -- URLSearchParams
	if not UrlParameters then
		return Url
	end

	if string.find(Url, "?") == nil then
		Url ..= "?"
	end

	local Params = {}
	for Index,Value in UrlParameters do -- Create a Array of Stringified Params
		table.insert(Params, `{tostring(Index)}={HttpService:UrlEncode(tostring(Value))}`)
	end

	Url ..= table.concat(Params, "&")

	return Url
end

function Module.HttpRequest(RequestOptions: RequestOptions): HttpResponse
	if typeof(RequestOptions) ~= "table" then
		return error(`RequestOptions missing!`)
	end
	
	if type(RequestOptions.Url) ~= "string" then
		return error(`RequestOptions "Url" argument missing!`)
	end
	
	if type(RequestOptions.Method) ~= "string" then
		return error(`RequestOptions "Method" argument missing!`)
	end
	if not HttpMethodsDict[RequestOptions.Method] then
		return error(`RequestOptions "Method" {RequestOptions.Method} is not a valid argument!`)
	end
	
	return RequestASync(RequestOptions)
end

return Module