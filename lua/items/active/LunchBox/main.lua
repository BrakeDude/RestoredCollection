local LunchBoxLocal = {}
local game = RestoredCollection.Game
local Helpers = RestoredCollection.Helpers
local sfx = RestoredCollection.SFX
local RepentogonTargetCol = REPENTOGON and RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX
	or (RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - 5)
local itemConfig = Isaac.GetItemConfig()
local pickupsAdded = false

---@param player EntityPlayer
---@return boolean
local function isNoRedHealthCharacter(player)
	local t = player:GetPlayerType()
	return REPENTOGON and player:GetHealthType() ~= HealthType.RED and player:GetHealthType() ~= HealthType.COIN
		or CustomHealthAPI and CustomHealthAPI.PersistentData.CharactersThatCantHaveRedHealth[t]
		or Helpers.IsGhost(player)
		or t == PlayerType.PLAYER_THESOUL
end

---@param player EntityPlayer
---@return boolean
local function DoesLunchBoxNeedsCharge(player)
	for slot = 0, 2 do
		for col = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX, RepentogonTargetCol, -1 do
			if player:GetActiveItem(slot) == col then
				local item = itemConfig:GetCollectible(player:GetActiveItem(slot))
				local charge = Helpers.GetCharge(player, slot)
				if charge < item.MaxCharges then
					return true
				end
			end
		end
	end
	return false
end

local function HPLeft(player, slot, hp, collectible)
	if player:GetActiveItem(slot) == collectible and hp > 0 then
		local item = itemConfig:GetCollectible(player:GetActiveItem(slot))
		local charge = Helpers.GetCharge(player, slot)
		if charge < item.MaxCharges then
			player:SetActiveCharge(math.min(charge + hp, item.MaxCharges), slot)
			RestoredCollection.HUD:FlashChargeBar(player, slot)
		end
		hp = math.max(0, charge + hp - item.MaxCharges)
	end
	return hp
end

local function AddPickupsToLunchBox()
	if CustomHealthAPI then
		CustomHealthAPI.Library.AddCallback(
			"RestoredCollection",
			CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH,
			0,
			function(player, key, hp)
				local typ = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
				if typ == CustomHealthAPI.Enums.HealthTypes.RED then
					for slot = 0, 2 do
						if REPENTOGON then
							hp =
								HPLeft(player, slot, hp, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX)
						else
							for i = 0, 5 do
								hp = HPLeft(
									player,
									slot,
									hp,
									RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i
								)
							end
						end
					end
					return key, hp
				end
			end
		)

		CustomHealthAPI.Library.AddCallback(
			"RestoredCollection",
			CustomHealthAPI.Enums.Callbacks.CAN_PICK_HEALTH,
			0,
			function(player, key)
				local typ = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
				if typ == CustomHealthAPI.Enums.HealthTypes.RED then
					if DoesLunchBoxNeedsCharge(player) then
						return true
					end
				end
			end
		)
	else
		LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, 1, function(player, pickup)
			pickup:PlayPickupSound()
		end)
		LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, 2, function(player, pickup)
			pickup:PlayPickupSound()
		end)
		LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED, 2, function(player, pickup)
			pickup:PlayPickupSound()
		end)
		LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, 4, function(player, pickup)
			pickup:PlayPickupSound()
		end)
		LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, 1, function(player, pickup)
			player:AddSoulHearts(1)
			pickup:PlayPickupSound()
		end)
		RestoredCollection:AddPriorityCallback(
			ModCallbacks.MC_PRE_PICKUP_COLLISION,
			CallbackPriority.IMPORTANT,
			function(_, pickup, collider, low)
				if collider.Type == EntityType.ENTITY_PLAYER and collider.Variant == 0 then
					local player = collider:ToPlayer()
					if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
						player = player:GetOtherTwin()
					end
					if
						DoesLunchBoxNeedsCharge(player)
						and LunchBox.GetPickupData(pickup.Variant) ~= nil
						and LunchBox.GetPickupData(pickup.Variant, pickup.SubType) ~= nil
					then
						if pickup:IsShopItem() then
							return
						else
							pickup:GetSprite():Play("Collect")
							pickup:Die()
							if pickup.OptionsPickupIndex ~= 0 then
								local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
								for _, entity in ipairs(pickups) do
									if
										entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex
										and (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
									then
										Isaac.Spawn(
											EntityType.ENTITY_EFFECT,
											EffectVariant.POOF01,
											0,
											entity.Position,
											Vector.Zero,
											nil
										)
										entity:Remove()
									end
								end
							end
						end
						local hp = LunchBox.GetPickupData(pickup.Variant, pickup.SubType).Charge

						if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
							hp = hp * 2
						end

						for slot = 0, 2 do
							if REPENTOGON then
								hp = HPLeft(
									player,
									slot,
									hp,
									RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX
								)
							else
								for i = 0, 5 do
									hp = HPLeft(
										player,
										slot,
										hp,
										RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i
									)
								end
							end
						end
						LunchBox.GetPickupData(pickup.Variant, pickup.SubType).Function(player, pickup)
						player:AddHearts(hp)
						RestoredCollection.Level:SetHeartPicked()
						RestoredCollection.Game:ClearStagesWithoutHeartsPicked()
						RestoredCollection.Game:SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
						return true
					end
				end
			end
		)
	end
end

if REPENTOGON then
	RestoredCollection:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, AddPickupsToLunchBox)
else
	RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
		if not pickupsAdded then
			AddPickupsToLunchBox()
			pickupsAdded = true
		end
	end)
end

---@param collectible CollectibleType | integer
---@param rng RNG
---@param player EntityPlayer
---@param useflag UseFlag | integer
---@param slot integer
---@param customvardata integer
function LunchBoxLocal:Use(collectible, rng, player, useflag, slot, customvardata)
	local LunchBoxPool = {}
	for i = 1, Helpers.GetMaxCollectibleID() do
		if ItemConfig.Config.IsValidCollectible(i) then
			if itemConfig:GetCollectible(i).Tags & ItemConfig.TAG_FOOD == ItemConfig.TAG_FOOD then
				table.insert(LunchBoxPool, i)
			end
		end
	end
	local food = LunchBoxPool[rng:RandomInt(#LunchBoxPool) + 1]
	local spawnpos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 20, true)
	local pickup =
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, food, spawnpos, Vector.Zero, nil)
			:ToPickup()
	sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0)
	if slot ~= -1 then
		local remove = false
		local wispSP = collectible
		if REPENTOGON then
			local itemDesc = player:GetActiveItemDesc(slot)
			wispSP = wispSP - itemDesc.VarData
			if itemDesc.VarData > 4 then
				remove = true
			else
				player:SetActiveVarData(itemDesc.VarData + 1, slot)
			end
		else
			if collectible == RepentogonTargetCol then
				remove = true
			else
				player:AddCollectible(collectible - 1, 0, false, slot)
			end
		end
		player:SetActiveCharge(Helpers.GetCharge(player, slot) - itemConfig:GetCollectible(collectible).MaxCharges)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			player:AddWisp(wispSP, player.Position)
		end
		return { Discharge = false, Remove = remove, ShowAnim = true }
	end
	return { Discharge = true, Remove = true, ShowAnim = true }
end
RestoredCollection:AddCallback(
	ModCallbacks.MC_USE_ITEM,
	LunchBoxLocal.Use,
	RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX
)
if not REPENTOGON then
	for i = 1, 5 do
		RestoredCollection:AddCallback(
			ModCallbacks.MC_USE_ITEM,
			LunchBoxLocal.Use,
			RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i
		)
	end
end
