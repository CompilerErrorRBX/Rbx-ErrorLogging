--- Http wrapper which provides error response handling with retries.
-- Can be configured to use exponential falloff on retries.
-- @author CompilerError
-- @module Http

local HttpService = game:GetService('HttpService');

local Http = {};

Http.RequestType = {
	GET = 'GET',
	POST = 'POST',
	HEAD = 'HEAD',
	PUT = 'PUT',
	PATCH = 'PATCH',
	DELETE = 'DELETE',
};

function Http.Get(url, headers, max_retries)
	return Http.Request(url, Http.RequestType.GET, nil, headers, max_retries)
end

function Http.Post(url, body, headers, max_retries)
	return Http.Request(url, Http.RequestType.POST, body, headers, max_retries)
end

function Http.Put(url, body, headers, max_retries)
	return Http.Request(url, Http.RequestType.PUT, body, headers, max_retries)
end

function Http.Patch(url, body, headers, max_retries)
	return Http.Request(url, Http.RequestType.PATCH, body, headers, max_retries)
end

function Http.Delete(url, body, headers, max_retries)
	return Http.Request(url, Http.RequestType.DELETE, body, headers, max_retries)
end

function Http.Request(url, request_type, body, headers, max_retries, retry)
	request_type = request_type or Http.RequestType.GET;
	body = body or {};
	headers = headers or {};
	max_retries = max_retries or 1;
	retry = retry and retry + 1 or 0;

	local request_headers = {
		['X-HTTP-Method-Override'] = request_type,
		['Content-Type'] = tostring(Enum.HttpContentType.ApplicationJson)
	};

	for key, value in pairs(headers) do
		request_headers[key] = value;
	end

	local no_body = (request_type == Http.RequestType.GET or Http.RequestType.HEAD);
	local response = nil;

  local _body = (not no_body) and type(body) == 'table' and HttpService:JSONEncode(body) or body;

  _body = (no_body) and nil or _body;

	local success, message = pcall(function()
		response = HttpService:RequestAsync({
			Url = url,
			Method = request_type == Http.RequestType.PUT and Http.RequestType.POST or request_type;
			Headers = request_headers,
			Body = _body
		});
	end);

	if (success and response and response.Success) then
		if (response.Body) then
			local data = response.Body;
			pcall(function()
				HttpService:JSONDecode(data);
			end);

			response.Body = data;
		end
	else
		if (retry < max_retries) then
			return Http.Request(url, request_type, body, headers, max_retries, retry);
		end
	end

	if (not success) then
		warn('[Http.Request] ' ..message);
	end

	return response;
end

return Http;
