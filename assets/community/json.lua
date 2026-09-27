--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community JSON)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- JSON State
-------------------------------------------------------------------------------

CommunityJSON = CommunityJSON or {}
CommunityJSON.null = CommunityJSON.null or {}
local arrayMarker = {}

-- The shipped Playground Lua sandbox does not expose the standard `math` table.
-- Detect NaN/infinities using number arithmetic only: finite n => n - n == 0,
-- while +/-infinity subtracts to NaN (which is unequal to itself).
local function IsFiniteNumber(value)
	if type(value) ~= 'number' or value ~= value then
		return false
	end
	local zero = value - value
	return zero == zero
end

function CommunityJSON.Array(value)
	value = value or {}
	setmetatable(value, arrayMarker)
	return value
end

-------------------------------------------------------------------------------
-- JSON Encoding
-------------------------------------------------------------------------------

local function EncodeString(value)
	local out = { '"' }
	for i = 1, string.len(value) do
		local b = string.byte(value, i)
		if b == 34 then table.insert(out, '\\"')
		elseif b == 92 then table.insert(out, '\\\\')
		elseif b == 8 then table.insert(out, '\\b')
		elseif b == 9 then table.insert(out, '\\t')
		elseif b == 10 then table.insert(out, '\\n')
		elseif b == 12 then table.insert(out, '\\f')
		elseif b == 13 then table.insert(out, '\\r')
		elseif b < 32 then table.insert(out, string.format('\\u%04x', b))
		else table.insert(out, string.char(b)) end
	end
	table.insert(out, '"')
	return table.concat(out)
end

local function TableIsArray(value)
	if getmetatable(value) == arrayMarker then
		return true, table.getn(value)
	end
	local count = 0
	local maxIndex = 0
	for key, _ in pairs(value) do
		if type(key) ~= 'number' or key < 1 or Floor(key) ~= key then
			return false, 0
		end
		count = count + 1
		if key > maxIndex then
			maxIndex = key
		end
	end
	if count == 0 then
		return false, 0
	end
	return count == maxIndex, maxIndex
end

local function EncodeValue(value, stack)
	local kind = type(value)
	if value == CommunityJSON.null or kind == 'nil' then
		return 'null'
	end
	if kind == 'boolean' then
		return value and 'true' or 'false'
	end
	if kind == 'number' then
		if not IsFiniteNumber(value) then
			error('CommunityJSON cannot encode non-finite numbers.')
		end
		return tostring(value)
	end
	if kind == 'string' then
		return EncodeString(value)
	end
	if kind ~= 'table' then
		error('CommunityJSON cannot encode type ' .. kind .. '.')
	end
	if stack[value] then
		error('CommunityJSON cannot encode recursive tables.')
	end
	stack[value] = true

	local isArray, maxIndex = TableIsArray(value)
	local out = {}
	if isArray then
		table.insert(out, '[')
		for i = 1, maxIndex do
			if i > 1 then
				table.insert(out, ',')
			end
			table.insert(out, EncodeValue(value[i], stack))
		end
		table.insert(out, ']')
	else
		table.insert(out, '{')
		local keys = {}
		for key, _ in pairs(value) do
			if type(key) ~= 'string' then
				error('CommunityJSON object keys must be strings.')
			end
			table.insert(keys, key)
		end
		table.sort(keys)
		for i, key in ipairs(keys) do
			if i > 1 then
				table.insert(out, ',')
			end
			table.insert(out, EncodeString(key))
			table.insert(out, ':')
			table.insert(out, EncodeValue(value[key], stack))
		end
		table.insert(out, '}')
	end

	stack[value] = nil
	return table.concat(out)
end

function CommunityJSON.Encode(value)
	return EncodeValue(value, {})
end

local function Utf8(codepoint)
	if codepoint <= 0x7F then
		return string.char(codepoint)
	elseif codepoint <= 0x7FF then
		return string.char(0xC0 + Floor(codepoint / 0x40), 0x80 + Mod(codepoint, 0x40))
	elseif codepoint <= 0xFFFF then
		return string.char(
			0xE0 + Floor(codepoint / 0x1000),
			0x80 + Mod(Floor(codepoint / 0x40), 0x40),
			0x80 + Mod(codepoint, 0x40)
		)
	elseif codepoint <= 0x10FFFF then
		return string.char(
			0xF0 + Floor(codepoint / 0x40000),
			0x80 + Mod(Floor(codepoint / 0x1000), 0x40),
			0x80 + Mod(Floor(codepoint / 0x40), 0x40),
			0x80 + Mod(codepoint, 0x40)
		)
	end
	error('Invalid Unicode codepoint in JSON string.')
end

local function HexValue(text)
	local value = tonumber(text, 16)
	if not value then
		error('Invalid JSON Unicode escape.')
	end
	return value
end

-------------------------------------------------------------------------------
-- JSON Decoding
-------------------------------------------------------------------------------

local function Decoder(text)
	local at = 1
	local length = string.len(text)

	-- Chocolatier's embedded Lua 5.0 string.sub can return nil when the
	-- requested start position is beyond the end of the string. Desktop Lua
	-- returns an empty string instead. Keep the decoder independent of that
	-- runtime difference so boundary checks never compare nil with digits.
	local function Slice(first, last)
		if first < 1 or first > length then
			return ""
		end
		return string.sub(text, first, last) or ""
	end

	local function CharAt(index)
		return Slice(index, index)
	end

	local function SkipSpace()
		while at <= length do
			local b = string.byte(text, at)
			if b == 32 or b == 9 or b == 10 or b == 13 then
				at = at + 1
			else
				break
			end
		end
	end

	local function ParseString()
		if CharAt(at) ~= '"' then
			error('Expected JSON string.')
		end
		at = at + 1
		local out = {}
		local literalStart = at
		while at <= length do
			local b = string.byte(text, at)
			if b == 34 then
				if at > literalStart then
					table.insert(out, Slice(literalStart, at - 1))
				end
				at = at + 1
				return table.concat(out)
			elseif b == 92 then
				if at > literalStart then
					table.insert(out, Slice(literalStart, at - 1))
				end
				at = at + 1
				if at > length then
					error('Unterminated JSON escape.')
				end
				local esc = CharAt(at)
				if esc == '"' or esc == '\\' or esc == '/' then table.insert(out, esc)
				at = at + 1
				elseif esc == 'b' then table.insert(out, string.char(8))
				at = at + 1
				elseif esc == 'f' then table.insert(out, string.char(12))
				at = at + 1
				elseif esc == 'n' then table.insert(out, '\n')
				at = at + 1
				elseif esc == 'r' then table.insert(out, '\r')
				at = at + 1
				elseif esc == 't' then table.insert(out, '\t')
				at = at + 1
				elseif esc == 'u' then
					local hex = Slice(at + 1, at + 4)
					if string.len(hex) ~= 4 then
						error('Incomplete JSON Unicode escape.')
					end
					local cp = HexValue(hex)
					at = at + 5
					if cp >= 0xD800 and cp <= 0xDBFF then
						if Slice(at, at + 1) ~= '\\u' then
							error('Missing low surrogate in JSON string.')
						end
						local low = HexValue(Slice(at + 2, at + 5))
						if low < 0xDC00 or low > 0xDFFF then
							error('Invalid low surrogate in JSON string.')
						end
						cp = 0x10000 + ((cp - 0xD800) * 0x400) + (low - 0xDC00)
						at = at + 6
					elseif cp >= 0xDC00 and cp <= 0xDFFF then
						error('Unexpected low surrogate in JSON string.')
					end
					table.insert(out, Utf8(cp))
				else
					error('Unknown JSON escape: \\' .. esc)
				end
				literalStart = at
			elseif b < 32 then
				error('Control character inside JSON string.')
			else
				at = at + 1
			end
		end
		error('Unterminated JSON string.')
	end

	local ParseValue

	-- Lua 5.0 ends the lexical scope of locals declared inside a repeat block
	-- before compiling the until condition. Do not use a repeat-local character
	-- in the condition: the shipped Chocolatier VM would resolve it as a global.
	local function IsDigit(value)
		return value ~= nil and value >= '0' and value <= '9'
	end

	local function ParseNumber()
		local start = at
		if CharAt(at) == '-' then
			at = at + 1
		end

		local first = CharAt(at)
		if first == '0' then
			at = at + 1
			local nextChar = CharAt(at)
			if IsDigit(nextChar) then
				error('Leading zero in JSON number.')
			end
		elseif IsDigit(first) and first ~= '0' then
			at = at + 1
			while IsDigit(CharAt(at)) do
				at = at + 1
			end
		else
			error('Invalid JSON number.')
		end

		if CharAt(at) == '.' then
			at = at + 1
			local digit = CharAt(at)
			if not IsDigit(digit) then
				error('JSON fraction requires digits.')
			end
			at = at + 1
			while IsDigit(CharAt(at)) do
				at = at + 1
			end
		end

		local exponent = CharAt(at)
		if exponent == 'e' or exponent == 'E' then
			at = at + 1
			local sign = CharAt(at)
			if sign == '+' or sign == '-' then
				at = at + 1
			end
			local digit = CharAt(at)
			if not IsDigit(digit) then
				error('JSON exponent requires digits.')
			end
			at = at + 1
			while IsDigit(CharAt(at)) do
				at = at + 1
			end
		end

		local raw = Slice(start, at - 1)
		local value = tonumber(raw)
		if not IsFiniteNumber(value) then
			error('Invalid or non-finite JSON number: ' .. raw)
		end
		return value
	end

	local function ParseArray()
		at = at + 1
		SkipSpace()
		local result = CommunityJSON.Array({})
		if CharAt(at) == ']' then
			at = at + 1
			return result
		end
		while true do
			table.insert(result, ParseValue())
			SkipSpace()
			local c = CharAt(at)
			if c == ']' then
				at = at + 1
				return result
			end
			if c ~= ',' then
				error('Expected comma in JSON array.')
			end
			at = at + 1
			SkipSpace()
		end
	end

	local function ParseObject()
		at = at + 1
		SkipSpace()
		local result = {}
		if CharAt(at) == '}' then
			at = at + 1
			return result
		end
		while true do
			local key = ParseString()
			SkipSpace()
			if CharAt(at) ~= ':' then
				error('Expected colon in JSON object.')
			end
			at = at + 1
			SkipSpace()
			if result[key] ~= nil then
				error('Duplicate key in JSON object: ' .. key)
			end
			result[key] = ParseValue()
			SkipSpace()
			local c = CharAt(at)
			if c == '}' then
				at = at + 1
				return result
			end
			if c ~= ',' then
				error('Expected comma in JSON object.')
			end
			at = at + 1
			SkipSpace()
		end
	end

	ParseValue = function()
		SkipSpace()
		local c = CharAt(at)
		if c == '"' then
			return ParseString()
		end
		if c == '{' then
			return ParseObject()
		end
		if c == '[' then
			return ParseArray()
		end
		if c == '-' or (c >= '0' and c <= '9') then
			return ParseNumber()
		end
		if Slice(at, at + 3) == 'true' then
			at = at + 4
			return true
		end
		if Slice(at, at + 4) == 'false' then
			at = at + 5
			return false
		end
		if Slice(at, at + 3) == 'null' then
			at = at + 4
			return CommunityJSON.null
		end
		error('Unexpected JSON token at byte ' .. tostring(at) .. '.')
	end

	local result = ParseValue()
	SkipSpace()
	if at <= length then
		error('Trailing data after JSON value.')
	end
	return result
end

function CommunityJSON.Decode(text)
	if type(text) ~= 'string' then
		error('CommunityJSON.Decode expects a string.')
	end
	return Decoder(text)
end
