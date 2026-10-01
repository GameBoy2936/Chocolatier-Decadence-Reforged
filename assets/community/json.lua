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

-- User-authored text comes from Playground's legacy Windows text controls. Most
-- strings are ASCII and some newer paths already contain UTF-8, but pasted or
-- typed punctuation can still arrive as Windows-1252 bytes (for example 0x96
-- for an en dash or 0xA0 for a non-breaking space). Passing those bytes through
-- verbatim produces invalid UTF-8 JSON and the Community service rejects the
-- request before it can parse the creation. Preserve valid UTF-8 sequences and
-- convert otherwise-invalid legacy bytes to JSON Unicode escapes.
local cp1252 =
{
	[0x80] = 0x20AC, [0x82] = 0x201A, [0x83] = 0x0192, [0x84] = 0x201E,
	[0x85] = 0x2026, [0x86] = 0x2020, [0x87] = 0x2021, [0x88] = 0x02C6,
	[0x89] = 0x2030, [0x8A] = 0x0160, [0x8B] = 0x2039, [0x8C] = 0x0152,
	[0x8E] = 0x017D, [0x91] = 0x2018, [0x92] = 0x2019, [0x93] = 0x201C,
	[0x94] = 0x201D, [0x95] = 0x2022, [0x96] = 0x2013, [0x97] = 0x2014,
	[0x98] = 0x02DC, [0x99] = 0x2122, [0x9A] = 0x0161, [0x9B] = 0x203A,
	[0x9C] = 0x0153, [0x9E] = 0x017E, [0x9F] = 0x0178,
}

local function UnicodeEscape(codepoint)
	if codepoint <= 0xFFFF then
		return string.format('\\u%04x', codepoint)
	end
	local value = codepoint - 0x10000
	local high = 0xD800 + Floor(value / 0x400)
	local low = 0xDC00 + Mod(value, 0x400)
	return string.format('\\u%04x\\u%04x', high, low)
end

local function ValidUtf8SequenceLength(value, at, length)
	local b1 = string.byte(value, at)
	local b2, b3, b4
	if at + 1 <= length then b2 = string.byte(value, at + 1) end
	if at + 2 <= length then b3 = string.byte(value, at + 2) end
	if at + 3 <= length then b4 = string.byte(value, at + 3) end

	if b1 >= 0xC2 and b1 <= 0xDF then
		if b2 and b2 >= 0x80 and b2 <= 0xBF then return 2 end
	elseif b1 == 0xE0 then
		if b2 and b2 >= 0xA0 and b2 <= 0xBF and b3 and b3 >= 0x80 and b3 <= 0xBF then return 3 end
	elseif (b1 >= 0xE1 and b1 <= 0xEC) or (b1 >= 0xEE and b1 <= 0xEF) then
		if b2 and b2 >= 0x80 and b2 <= 0xBF and b3 and b3 >= 0x80 and b3 <= 0xBF then return 3 end
	elseif b1 == 0xED then
		if b2 and b2 >= 0x80 and b2 <= 0x9F and b3 and b3 >= 0x80 and b3 <= 0xBF then return 3 end
	elseif b1 == 0xF0 then
		if b2 and b2 >= 0x90 and b2 <= 0xBF and b3 and b3 >= 0x80 and b3 <= 0xBF and b4 and b4 >= 0x80 and b4 <= 0xBF then return 4 end
	elseif b1 >= 0xF1 and b1 <= 0xF3 then
		if b2 and b2 >= 0x80 and b2 <= 0xBF and b3 and b3 >= 0x80 and b3 <= 0xBF and b4 and b4 >= 0x80 and b4 <= 0xBF then return 4 end
	elseif b1 == 0xF4 then
		if b2 and b2 >= 0x80 and b2 <= 0x8F and b3 and b3 >= 0x80 and b3 <= 0xBF and b4 and b4 >= 0x80 and b4 <= 0xBF then return 4 end
	end
	return nil
end

local function EncodeString(value)
	local out = { '"' }
	local length = string.len(value)
	local i = 1
	while i <= length do
		local b = string.byte(value, i)
		if b == 34 then table.insert(out, '\\"')
		elseif b == 92 then table.insert(out, '\\\\')
		elseif b == 8 then table.insert(out, '\\b')
		elseif b == 9 then table.insert(out, '\\t')
		elseif b == 10 then table.insert(out, '\\n')
		elseif b == 12 then table.insert(out, '\\f')
		elseif b == 13 then table.insert(out, '\\r')
		elseif b < 32 then table.insert(out, string.format('\\u%04x', b))
		elseif b < 0x80 then table.insert(out, string.char(b))
		else
			local sequenceLength = ValidUtf8SequenceLength(value, i, length)
			if sequenceLength then
				table.insert(out, string.sub(value, i, i + sequenceLength - 1))
				i = i + sequenceLength - 1
			else
				local codepoint = cp1252[b] or b
				table.insert(out, UnicodeEscape(codepoint))
			end
		end
		i = i + 1
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
