return function()
	local HttpWrapper = require(script.Parent.Parent) -- HttpWrapper Module
	local HttpService = game:GetService("HttpService")
	
	local function shallow_eq(o1, o2, ignore_mt)
		if o1 == o2 then return true end
		local o1Type = type(o1)
		local o2Type = type(o2)
		if o1Type ~= o2Type then return false end
		if o1Type ~= 'table' then return false end

		if not ignore_mt then
			local mt1 = getmetatable(o1)
			if mt1 and mt1.__eq then
				--compare using built in method
				return o1 == o2
			end
		end

		local keySet = {}

		for key1, value1 in pairs(o1) do
			local value2 = o2[key1]
			if value2 == nil or shallow_eq(value1, value2, ignore_mt) == false then
				return false
			end
			keySet[key1] = true
		end

		for key2, _ in pairs(o2) do
			if not keySet[key2] then return false end
		end
		return true
	end
	
	describe("URLParams", function()
		it("should add URLParams to an URL", function()
			local Url = HttpWrapper.AddURLParams("https://www.google.com", {
				Name = "Tobie",
				Data = "Some random data",
				Test = "StringVariable",
			})

			expect(Url).to.be.equal("https://www.google.com?Test=StringVariable&Name=Tobie&Data=Some%20random%20data")
		end)
		
		it("should perform a simple PUT request with URLParams", function()
			local response = HttpWrapper.HttpRequest({
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

			expect(response).to.be.ok()
			expect(response.Success).to.be.equal(true)
			expect(response.StatusCode).to.be.equal(200)
			
			local Args = HttpService:JSONDecode(response.Body).args
			
			expect(shallow_eq(Args, {
				Name = "Tobie",
				Data = "Some random data",
				Test = "StringVariable"
			}, true)).to.equal(true)
		end)
	end)
	
	describe("Request", function()
		it("should perform a simple GET request", function()
			local response = HttpWrapper.HttpRequest({
				Url = "https://httpbin.org/get",
				Method = "GET"
			})
			
			expect(response).to.be.ok()
			expect(response.Success).to.be.equal(true)
			expect(response.StatusCode).to.be.equal(200)
		end)
		
		it("should perform a simple POST request", function()
			local response = HttpWrapper.HttpRequest({
				Url = "https://httpbin.org/post",
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode({
					Hello = "Post"
				})
			})

			expect(response).to.be.ok()
			expect(response.Success).to.be.equal(true)
			expect(response.StatusCode).to.be.equal(200)
		end)
		
		it("should perform a simple PUT request", function()
			local response = HttpWrapper.HttpRequest({
				Url = "https://httpbin.org/put",
				Method = "PUT",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode({
					Hello = "Put"
				})
			})

			expect(response).to.be.ok()
			expect(response.Success).to.be.equal(true)
			expect(response.StatusCode).to.be.equal(200)
		end)
		
		it("should perform a simple PATCH request", function()
			local response = HttpWrapper.HttpRequest({
				Url = "https://httpbin.org/patch",
				Method = "PATCH",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode({
					Hello = "Patch"
				})
			})

			expect(response).to.be.ok()
			expect(response.Success).to.be.equal(true)
			expect(response.StatusCode).to.be.equal(200)
		end)
		
		it("should perform a simple DELETE request", function()
			local response = HttpWrapper.HttpRequest({
				Url = "https://httpbin.org/delete",
				Method = "DELETE",
			})

			expect(response).to.be.ok()
			expect(response.Success).to.be.equal(true)
			expect(response.StatusCode).to.be.equal(200)
		end)
		
		it("should handle unsuccessful requests", function()
			local response = HttpWrapper.HttpRequest({
				Url = "https://httpbin.org/status/400",
				Method = "GET",
			})

			expect(response).to.be.ok()
			expect(response.Success).to.be.equal(false)
			expect(response.StatusCode).to.be.ok()
			expect(response.StatusMessage).to.be.ok()
		end)
		
		it("should reject request without a specified Url", function()
			expect(function()
				local response = HttpWrapper.HttpRequest({
					Url = nil,
					Method = "GET",
				})
			end).to.throw()
		end)
		
		it("should reject request without a specified Method", function()
			expect(function()
				local response = HttpWrapper.HttpRequest({
					Url = "https://httpbin.org/get",
					Method = nil,
				})
			end).to.throw()
		end)
	end)
end