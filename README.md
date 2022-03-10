# ox_accounts
Standalone resource to handle player currency ("accounts") such as bank accounts, tokens, cryptocurrency, etc.  
Further logic needs to be implemented in any framework or resource utilising these accounts.  

Resource can be loaded as a module directly into a framework if desired.


## Requirements
- [oxmysql](https://github.com/overextended/oxmysql)


## Database
Example table structure for ox_core and es_extended.  
You will need to change the datatype for charid and the referenced column (characters.charid).

### ox_core
```sql
CREATE TABLE IF NOT EXISTS `user_accounts` (
  `charid` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  UNIQUE KEY `name` (`name`,`charid`) USING BTREE,
  KEY `FK_user_accounts_characters` (`charid`) USING BTREE,
  CONSTRAINT `FK_user_accounts_characters` FOREIGN KEY (`charid`) REFERENCES `characters` (`charid`) ON DELETE CASCADE
) ENGINE=InnoDB;
```

### es_extended
```sql
CREATE TABLE IF NOT EXISTS `user_accounts` (
  `charid` varchar(60) NOT NULL,
  `name` varchar(50) NOT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  UNIQUE KEY `name` (`name`,`charid`) USING BTREE,
  KEY `FK_user_accounts_characters` (`charid`) USING BTREE,
  CONSTRAINT `FK_user_accounts_characters` FOREIGN KEY (`charid`) REFERENCES `users` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB;
```


## Usage
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
