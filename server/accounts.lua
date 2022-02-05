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

local Query = {
	ACCOUNT_NAMES = 'SELECT UNIQUE name FROM accounts',
	SELECT_ACCOUNTS = 'SELECT name, amount from accounts WHERE charid = ?',
	UPDATE_ACCOUNT = 'INSERT INTO accounts (name, charid, amount) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE amount = VALUES(amount)',
}

---@param source number server id to identify the player
---@param charid number | string unique identifier used to reference the character in the database
---@return table<string, number> accounts
function accounts.load(source, charid)
	players[source] = charid

	local result = MySQL.query.await(Query.SELECT_ACCOUNTS, { charid })
	for _, account in pairs(result) do
		accountData[charid][account.name] = account.amount
	end
end

---@param source number server id to identify the player
---@param account? string return the amount in the given account
---@return number | table<string, number>
---Leave account undefined to get a table of all accounts and amounts
function accounts.get(source, account)
	if source then
		source = players[source]

		if account then
			return accountData[source][account]
		end

		return accountData[source]
	end
end
provideExport('get', accounts.get)

---@param source number server id to identify the player
---@param account string name of the account to adjust
---@param amount number
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

---@param source number server id to identify the player
---@param account string name of the account to adjust
---@param amount number
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

---@param source number server id to identify the player
---@param account string name of the account to adjust
---@param amount number
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
