#!/usr/bin/lua
local args = {...}
local path = args[1]

local registry = setmetatable({ class = {}, instance = {} }, { __mode='k' })
local classpath = {}

local instantiate

local baseClass = {
	__index = function(self, key)
		if registry.class[self].vars[key].private then
			error(key..' has private access in '..registry.class[self].name..'.', 2)
		elseif not registry.class[self].vars[key].static then
			error('Non static '..(type(registry.class[self].vars[key].value) == 'function' and 'method' or 'variable')..]' cannot be referenced from a static context.', 2)
		end
		return registry.class[self].vars[key].value
	end,

	__newindex = function(self, key, val)
		if registry.class[self].vars[key].private then
			error(key..' has private access in '..registry.class[self].name..'.', 2)
		elseif registry.class[self].vars[key].final then
			error('Cannot assign a value to final variable'..key..'.', 2)
		end
		registry.class[self].vars[key].value = val
	end,

	__call = function(self, ...)
		return instantiate(self, ...)
	end,

	__tostring = function(self)
		error('Non static method cannot be referenced from a static context.', 2)
	end,

	__metatable = false
}

local baseInstance = {
	__index = function(self, key)
		if registry.instance[self].vars[key].private then
			error(key..' has private access in '..registry.class[registry.instance[self].superClass].name..'.', 2)
		elseif registry.class[self].vars[key].static then
			return registry.class[registry.instance[self].superClass].vars[key].value
		end
		return registry.class[self].vars[key].value
	end,

	__newindex = function(self, key, val)
		if registry.class[self].vars[key].private then
			error(key..' has private access in '..registry.class[registry.instance[self].superClass].name..'.', 2)
		elseif registry.class[self].vars[key].final then
			error('Cannot assign a value to final variable'..key..'.', 2)
		end
		registry.class[self].vars[key].value = val
	end,

	__tostring = function(self)
		if registry.class[self].meta.tostring then
			return registry.class[self].meta.tostring()
		else
			return registry.class[registry.instance[self].superClass].name..'@'..registry.class[self].system.addr
		end
	end,

	__metatable = false
}

local function assert(condition, msg, lvl)
	if not condition then error(msg, lvl + 1) end
end

for k,v in ipairs({'add', 'sub', 'mul', 'div', 'mod', 'pow', 'unm', 'concat', 'eq', 'lt', 'le'}) do
	baseClass['__'..v] = function(self, ...)
		registry.class[self].meta[v](...)
	end
end

local function class(qualifiedpath, public, final, abstract, static)
	local class = {}
	registry.class[class] = {
		name = qualifiedpath:match('([^%.]+)$'),
		package = qualifiedpath:match('(.-)[^%.]+$'):gsub('.$','')
		qualifiedpath = qualifiedpath
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
		meta = {}
	}
	local currpkg = classpath
	for seg in qualifiedpath:gmatch('[^%.]+') do
		if seg == registry.class[class].name then
			currpkg[seg] = class
			break
		else
			currpkg[seg] = {}
			currpkg = currpkg[seg]
		end
	end
	return setmetatable(class,baseClass)
end

local function instantiate(class, ...)
	assert(registry.class[self].__system.__abstract, 'Cannot instantiate from abstract class.', 3)
	local instance = {}
	registry.instance[instance] = {
		system = {
			type = "Instance",
			superClass = class,
			addr = tostring(instance)
		},
		vars = {
			toString = {value = baseInstance.__tostring, public = true}
		},
		meta = {}
	}
	local instance = setmetatable(instance, baseInstance)
	if registry.class[class].constructor then
		registry.class[class].constructor(instance, ...)
	end
	return instance
end
