#!/usr/bin/lua
local args = {...}
local path = args[1]

local registry = setmetatable({ class = {}, object = {}, interface = {} }, { __mode='k' })

local construct

local baseClass = {
	__index = function(self, key)
		if registry.class[self].vars[key].isPrivate then
			error('Cannot access private variable.')
		end
		return registry.class[self].vars[key].value
	end,

	__newindex = function(self, key, val)
		if registry.class[self].vars[key].isPrivate then
			error('Cannot access private variable.')
		else registry.class[self].vars[key].isFinal then
			error('Cannot modify final variable.')
		end
		registry.class[self].vars[key].value = val
	end,

	__call = function(self, ...)
		return instantiate(self)
	end,

	__tostring = function(self)
		if registry.class[self].meta.tostring then
			return registry.class[self].meta.tostring()
		else
			return 'class: <'..registry.class[self].system.addr..'>'
		end
	end,

	__metatable = false
}

for k,v in ipairs({'add', 'sub', 'mul', 'div', 'mod', 'pow', 'unm', 'concat', 'eq', 'lt', 'le'}) do
	baseClass['__'..v] = function(self, ...)
		registry.class[self].meta[v](...)
	end
end

local function class(public, final, abstract, static)
	local class = {}
	registry.class[class] = {
		system = {
			type = "Class",
			public = public or false,
			final = final or false,
			abstract = abstract or false,
			static = static or false,
			superClass = false,
			subClasses = {},
			interfaces = {},
			addr = tostring(class)
		},
		vars = {},
		meta = {}
	}
	return setmetatable(class,baseClassMt)	
end