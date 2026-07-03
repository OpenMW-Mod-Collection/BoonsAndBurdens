---@diagnostic disable: assign-type-mismatch
---@omw-context local | global
local messages = {}

local function pickRandomMessage(l10n, messageKey, context)
    local messageOptions = {}
    local i = 1
    while true do
        local msgKey = ("%s_%d"):format(messageKey, i)
        local msg = l10n(msgKey, context)
        if msgKey ~= msg then
            messageOptions[#messageOptions + 1] = msg
        else
            break
        end
        i = i + 1
    end
    return messageOptions[math.random(#messageOptions)]
end

messages.show = function(l10n, player, messageKey, context)
    local msg = pickRandomMessage(l10n, messageKey, context)
    player:sendEvent("ShowMessage", { message = msg })
end

return messages
