import 'lua.util.logging.*'

ExampleLogger('public', 'class')

private_static.instance = nil

function public_static:getInstance()
	if not self.instance then
		self.instance = Logger('ExampleLogger')
	end
	return self.instance
end

function public:info(msg)
	self.instance:log(Level.INFO, msg)
end

function public:error(msg)
	self.instance:log(Level.ERROR, msg)
end

function public:warning(msg)
	self.instance:log(Level.WARNING, msg)
end

function public:fine(msg)
	self.instance:log(Level.FINE, msg)
end

function public:finer(msg)
	self.instance:log(Level.FINER, msg)
end