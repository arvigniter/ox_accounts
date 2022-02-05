# Yet another WIP resource

Standalone resource to handle player currency ("accounts") such as bank accounts, tokens, cryptocurrency, etc.  
Further logic needs to be implemented in any framework or resource utilising these accounts.  

Resource can be loaded as a module directly into a framework if desired (this will be done for ox_core).


Accounts management resource with no hardcoded framework-dependence.  
Can be integrated into a framework with imports, or kept standalone and called via exports.  

## Requirements
- [OxMySQL](https://github.com/overextended/oxmysql)


### Usage

Modify the following query where `YOUR_TABLE` matches your users table, and `YOUR_IDENTIFIER` is the column used to identitiy characters.  
In ESX, this would be 'users' and 'identifier'.
```sql
CREATE TABLE `accounts` (
  `charid` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `amount` int(11) NOT NULL,
  UNIQUE KEY `name` (`name`,`charid`),
  KEY `FK_accounts` (`charid`),
  CONSTRAINT `accounts_ibfk_1` FOREIGN KEY (`charid`) REFERENCES `YOUR_TABLE` (`YOUR_IDENTIFIER`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB;
```

Once character data has been loaded in your framework you should immediately load the account data as well.
```lua
---@param source number server id to identify the player
---@param charid number | string unique identifier used to reference the character in the database
---@return table<string, number> accounts

local accounts = exports.ox_accounts:load(source, charid)
```

Once account data has been loaded for a player, you can use the get function to reference it.
```lua
---@param source number server id to identify the player
---@param account? string return the amount in the given account
---@return number | table<string, number>
---Leave account undefined to get a table of all accounts and amounts

local accounts = exports.ox_accounts:get(source)
-- {fleeca = 420}

local fleeca = exports.ox_accounts:get(source, 'fleeca')
-- 420
```

You can adjust the balance of an account by using set, add, and remove.
```lua
---@param source number server id to identify the player
---@param account string name of the account to adjust
---@param amount number

exports.ox_accounts:add(source, 'fleeca', 420)
exports.ox_accounts:set(source, 'fleeca', 420)
exports.ox_accounts:remove(source, 'fleeca', 420)
```
