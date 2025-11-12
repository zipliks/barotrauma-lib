---@diagnostic disable: undefined-global, undefined-doc-name, undefined-field

--[[
Barotrauma Lua Library
Reusable functions for character health, chat, table operations, inventory, and more.
Reference: https://evilfactory.github.io/LuaCsForBarotrauma/lua-docs/
]]

local IAffliction = {}
local ITable = {}
local IChat = {}
local IItem = {}
local IEnum = {}
local IGame = {}

-- InvSlotType enum values
IEnum.InvSlotType = {
    None = 0,
    Any = 1,
    LeftHand = 4,
    RightHand = 2,
    Head = 8,
    InnerClothes = 16,
    OuterClothes = 32,
    Headset = 64,
    Card = 128,
    Bag = 256,
    HealthInterface = 512,
}

-- Color enum values
IEnum.Color = {
	Red = Color(255, 0, 0, 255),
    Green = Color(0, 255, 0, 255),
    Blue = Color(0, 0, 255, 255),
    Yellow = Color(255, 255, 0, 255),
    Cyan = Color(0, 255, 255, 255),
    Magenta = Color(255, 0, 255, 255),
    White = Color(255, 255, 255, 255),
    Black = Color(0, 0, 0, 255),
    Orange = Color(255, 165, 0, 255),
    Gray = Color(128, 128, 128, 255),
    LightGray = Color(211, 211, 211, 255),
    DarkGray = Color(64, 64, 64, 255)
}


--- Checks if a character has a specific affliction.
--- @param character Barotrauma.Character: The character to check.
--- @param affliction string: The affliction identifier to look for.
--- @return boolean boolean: True if the affliction is present, false otherwise.
function IAffliction.HasAffliction(character, affliction)
    local aff = character.CharacterHealth.GetAffliction(affliction)
    return aff ~= nil
end

--- Applies an affliction to a character's limb.
--- @param character Barotrauma.Character: The character to apply the affliction to.
--- @param limb Limb: The limb to apply the affliction to. If nil, applies to body.
--- @param identifier string: The affliction identifier.
--- @param strength number: The strength of the affliction.
--- @return nil nil: returns nothing but `return true` hides the message
function IAffliction.GiveAffliction(character, limb, identifier, strength)
    local affPrefab = AfflictionPrefab.Prefabs[identifier]
    if character == nil then return end
    if not limb then
        limb = LimbType.Body
    end
    character.CharacterHealth.ApplyAffliction(limb, affPrefab.Instantiate(strength))
    return true
end


--- Checks if a value exists in a table.
--- @param array table: The table to search.
--- @param value any: The value to look for.
--- @return boolean boolean: True if found, false otherwise.
function ITable.IsInTable(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

--- Removes the first occurrence of a value from a table.
--- @param array table: The table to modify.
--- @param value any: The value to remove.
function ITable.RemoveElementByName(array, value)
    for i, v in ipairs(array) do
        if v == value then
            table.remove(array, i)
            break
        end
    end
end

--- Clears all elements from a table.
--- @param array table: The table to clear.
function ITable.ClearTable(array)
    for i = #array, 1, -1 do
        table.remove(array, i)
    end
end


--- Sends a message to chat.
--- @param message string: The message to display.
--- @param title string: The chat message title.
--- @param color Color: The color of the message in RGBA format.
function IChat.PrintChat(message, title, color)
	local color = color or IEnum.Color.White
    if SERVER then
        IGame.SendMessage(message, ChatMessageType.Server)
    else
        local chatMessage = ChatMessage.Create(title, message, ChatMessageType.Server, nil)
        chatMessage.Color = color
        IGame.ChatBox.AddMessage(chatMessage)
    end
end

--- Sends a direct message to a client.
--- @param client Client: The client to send the message to.
--- @param title string: The chat message title.
--- @param message string: The message to send.
--- @param color Color: The color of the message in RGBA format.
function IChat.DMClient(client, title, message, color)
	local color = color or IEnum.Color.White
    if SERVER then
        if client == nil then return end
        title = title or ""
        local chatMessage = ChatMessage.Create(title, message, ChatMessageType.Server, nil)
        chatMessage.Color = color
        IGame.SendDirectChatMessage(chatMessage, client)
    else
        IChat.PrintChat(message, title, color)
    end
end

--- Sends a message to all clients.
--- @param messageAuthor string: The author/title of the message.
--- @param message string: The message to send.
--- @param color Color: The color of the message in RGBA format.
function IChat.SendMessageToAll(messageAuthor, message, color)
	local color = color or IEnum.Color.White
    if SERVER then
        for _, client in pairs(Client.ClientList) do
            IChat.DMClient(client, messageAuthor, message, color)
        end
    else
        IChat.PrintChat(message, messageAuthor, color)
    end
end


--- Finds an item by identifier in a character's inventory.
--- @param character Barotrauma.Character: The character whose inventory to search.
--- @param identifier string: The item identifier to search for.
--- @return Item|nil Item: The found item or nil if not found.
function IItem.FindItemByIdentifier(character, identifier)
    if not character or not identifier then return nil end
    if not character.Inventory then return nil end
    return character.Inventory.FindItemByIdentifier(identifier, true)
end

--- Gets an item in a specific limb slot.
--- @param character Barotrauma.Character: The character whose inventory to search.
--- @param limbSlot number: The limb slot to check.
--- @return Item|nil Item: The found item or nil if not found.
function IItem.GetItemInLimbSlot(character, limbSlot)
    if not character or not limbSlot then return nil end
    if not character.Inventory then return nil end
    return character.Inventory.GetItemInLimbSlot(limbSlot)
end

--- Checks if an item has any of the given identifiers or tags.
--- @param item Item: The item to check.
--- @param identifiersOrTags table|string: A table or string of identifiers/tags to check.
--- @return boolean boolean: True if the item has any of the identifiers/tags, false otherwise.
function IItem.HasIdentifierOrTags(item, identifiersOrTags)
    if not item or not identifiersOrTags then return false end
    if type(identifiersOrTags) == "string" then
        return item.HasIdentifierOrTags({identifiersOrTags})
    end
    return item.HasIdentifierOrTags(identifiersOrTags)
end


--- Checks if game is paused (single-player)
--- @return boolean boolean
function IGame.IsPaused()
	if SERVER then
		return false
	end

	return Game.Paused
end

return {
    IAffliction = IAffliction,
    ITable = ITable,
    IChat = IChat,
    IItem = IItem,
	IEnum = IEnum,
	IGame = IGame
}
