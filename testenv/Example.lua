import 'lua.util.logging.*'

Example('public', 'class')

private_static.logger = ExampleLogger.getInstance()

function public_static:main()
	self.logger:addHandler(StreamHandler(System.out, Formatter()))
	self.logger:addHandler(FileHandler('test.log'))
	self:log('INFO', 'Logger set up.')
end