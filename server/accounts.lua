local function provideExport(exportName, func)
	AddEventHandler(('__cfx_export_ox_accounts_%s'):format(exportName), function(setCB)
		setCB(func)
	end)
end

local accounts = {
	list = {},
}

local players = {}

local accountData = setmetatable({}, {
	__index = function(self, index)
		self[index] = {}
		return self[index]
	end
})

---@param name string
--- ```lua
--- exports.ox_accounts:registerAccount('fleeca')
--- ```
function accounts.register(name)
	accounts.list[name] = true
end
provideExport('registerAccount', accounts.register)

local Query = {
	ACCOUNT_NAMES = 'SELECT UNIQUE name FROM accounts',
	SELECT_ACCOUNTS = 'SELECT name, amount from accounts WHERE charid = ?',
	UPDATE_ACCOUNT = 'INSERT INTO accounts (name, charid, amount) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE amount = VALUES(amount)',
}

MySQL.ready(function()
	for _, account in pairs(MySQL.query.await(Query.ACCOUNT_NAMES)) do
		accounts.register(account.name)
	end
end)

function accounts.load(source, charid)
	players[source] = charid

	local result = MySQL.query.await(Query.SELECT_ACCOUNTS, { charid })
	for _, account in pairs(result) do
		if not accounts.list[account.name] then
			accounts.register(account.name)
		end

		accountData[charid][account.name] = account.amount
	end
end

function accounts.get(source, account)
	if source then
		source = players[source]

		if account then
			return accountData[source][account]
		end

		return accountData[source]
	end

	return accounts.list
end
provideExport('get', accounts.get)

function accounts.add(source, account, amount)
	if source then
		source = players[source]

		if not accountData[source][account] then
			accountData[source][account] = amount
		else
			accountData[source][account] += amount
		end
	end
end
provideExport('add', accounts.add)

function accounts.remove(source, account, amount)
	if source then
		source = players[source]

		if not accountData[source][account] then
			accountData[source][account] = amount
		else
			accountData[source][account] -= amount
		end
	end
end
provideExport('remove', accounts.remove)

function accounts.set(source, account, amount)
	if source then
		source = players[source]
		accountData[source][account] = amount
	end
end
provideExport('set', accounts.add)

function accounts.save(source, account)
	source = players[source]
	local amount = accountData[source][account]

	MySQL.prepare(Query.UPDATE_ACCOUNT, { account, source, amount })
end
provideExport('save', accounts.save)

function accounts.saveAll(source, remove)
	local parameters = {}
	local size = 0

	if source then
		source = players[source]

		for account, amount in pairs(accountData[source]) do
			size += 1
			parameters[size] = { account, source, amount }
		end

		if remove then
			accountData[source] = nil
		end
	else
		for charid, data in pairs(accountData) do
			for account, amount in pairs(data) do
				size += 1
				parameters[size] = { account, charid, amount }
			end
		end
	end

	MySQL.prepare(Query.UPDATE_ACCOUNT, parameters)
end
provideExport('saveAll', accounts.saveAll)

if server then
	server.accounts = accounts
end
