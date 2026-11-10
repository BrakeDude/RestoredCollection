local LuckySevenLudovico = {}
local Helpers = RestoredCollection.Helpers

---@param tear EntityTear
function LuckySevenLudovico:UpdateLudoTear(tear)
    if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end
    local player = Helpers.GetPlayerFromTear(tear)
    if player == nil then return end
    if not player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then return end
    local rng = tear:GetDropRNG()
    local chance = Helpers.GetLuckySevenChance(player)
    local data = Helpers.GetData(tear)
    if (not data.LuckySevenTearLudoCountDown or data.LuckySevenTearLudoCountDown <= 0) then
        if rng:RandomInt(5000) <= chance then
            data.IsLuckySevenTear = true
            data.LuckySevenTearLudoCountDown = 10
            tear.CollisionDamage = tear.CollisionDamage * Helpers.GetLuckySevenDamageMult(player)
        else
            data.IsLuckySevenTear = nil
        end
    elseif data.LuckySevenTearLudoCountDown and data.LuckySevenTearLudoCountDown > 0 then
        data.LuckySevenTearLudoCountDown = data.LuckySevenTearLudoCountDown - 1
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, LuckySevenLudovico.UpdateLudoTear)