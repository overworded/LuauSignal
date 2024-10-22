local Signal = {}
Signal.__index = Signal


local Connection = {}
Connection.__index = Connection

export type Signal = {
	Connections: {() -> ()}
}

export type Connection = {
	Signal: Signal,
	Callback: () -> ()
}

function Signal.new(): Signal
	local self = setmetatable({}, Signal)

	self.Connections = {}

	return self
end

function Connection.new(Signal: Signal, Callback: () -> ()): Connection
	local self = setmetatable({}, Connection)

	self.Signal = Signal
	self.Callback = Callback

	return self
end

function Connection:Disconnect()
	self.Signal.Connections[self.Index] = nil
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

function Signal:Connect(Callback: () -> ()): Connection
	local Connection = Connection.new(self, Callback)
	local Index = tostring(Callback)

	self.Connections[Index] = Connection
	Connection.Index = Index

	return Connection
end

function Signal:Fire(...)
	for _,Connection: Connection in next, self.Connections do
		task.spawn(Connection.Callback, ...)
	end
end

function Signal:Destroy()
	for _,Connection: Connection in next,self.Connections do
		Connection:Disconnect()
	end

	setmetatable(self, nil)
	table.clear(self.Connections)
	table.clear(self)
	table.freeze(self)
end

return Signal
