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

local function HPLeft(player, hp)
	for slot = 0, 2 do
		for collectible = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX, RepentogonTargetCol, -1 do
			if player:GetActiveItem(slot) == collectible and hp > 0 then
				local item = itemConfig:GetCollectible(player:GetActiveItem(slot))
				local charge = Helpers.GetCharge(player, slot)
				if charge < item.MaxCharges then
					player:SetActiveCharge(math.min(charge + hp, item.MaxCharges), slot)
					RestoredCollection.HUD:FlashChargeBar(player, slot)
				end
				hp = math.max(0, charge + hp - item.MaxCharges)
			end
		end
	end

	return hp
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


local function AddPickupsToLunchBox()
	LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED,
		{
			CollectSound = SoundEffect.SOUND_BOSS2_BUBBLES,
			HealthAmount = 1,
			HealthKeys = { "RED_HEART" },
			OnCollect = function(player, pickup)
				player:AddSoulHearts(1)
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 0)
			end,
			IsHeart = true
		}
	)
	if RepentancePlusMod then
		LunchBox.AddPickup(
			PickupVariant.PICKUP_HEART,
			RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HOARDED,
			{
				CollectSound = SoundEffect.SOUND_BOSS2_BUBBLES,
				HealthAmount = 8,
				HealthKeys = { "RED_HEART" },
				IsHeart = true
			}

		)
		LunchBox.AddPickup(
			PickupVariant.PICKUP_HEART,
			RepentancePlusMod.CustomPickups.TaintedHearts.HEART_CURDLED,
			{
				OnCollect = function(player)
					sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
					sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
					local s = isNoRedHealthCharacter(player) and 1 or 0
					if
						player:GetPlayerType() == PlayerType.PLAYER_THELOST
						or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B
						or player:GetPlayerType() == PlayerType.PLAYER_BETHANY
					then
						s = 3
					elseif
						player:GetPlayerType() == PlayerType.PLAYER_KEEPER
						or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B
					then
						s = 4
					elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
						s = 5
					end
					local trueCollider = player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B and player:GetOtherTwin()
						or player
					CustomHealthAPI.PersistentData.IgnoreSumptoriumHandling = true
					Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, s, trueCollider.Position, Vector.Zero, trueCollider)
					CustomHealthAPI.PersistentData.IgnoreSumptoriumHandling = false
				end,
				HealthAmount = 2,
				HealthKeys = { "RED_HEART" },
				IsHeart = true,
			}
		)
		LunchBox.AddPickup(
			PickupVariant.PICKUP_HEART,
			RepentancePlusMod.CustomPickups.TaintedHearts.HEART_SAVAGE,
			{
				CollectSound = SoundEffect.SOUND_BOSS2_BUBBLES,
				HealthAmount = 2,
				HealthKeys = { "RED_HEART" },
				IsHeart = true,
				OnCollect = function(player)
					RepentancePlusMod.addTemporaryDmgBoost(player)
				end,
			}
		)
		LunchBox.AddPickup(
			PickupVariant.PICKUP_HEART,
			RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HARLOT,
			{
				CollectSound = SoundEffect.SOUND_BOSS2_BUBBLES,
				HealthAmount = 1,
				HealthKeys = { "RED_HEART" },
				IsHeart = true,
				OnCollect = function(player)
					player
						:GetEffects()
						:AddCollectibleEffect(RepentancePlusMod.CustomCollectibles.HARLOT_FETUS_NULL, false, 1)
					player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
				end,
			}
		)
		LunchBox.AddPickup(
			PickupVariant.PICKUP_HEART,
			RepentancePlusMod.CustomPickups.TaintedHearts.HEART_DESERTED,
			{
				CollectSound = SoundEffect.SOUND_BOSS2_BUBBLES,
				HealthAmount = 1,
				HealthKeys = { "RED_HEART" },
				AllowCandyHeartSoulLocketBonus = true,
				AllowImmaculateConception = false,
				IsHeart = true,
				OnCollect = function(player, pickup)
					player:AddBlackHearts(1)
					sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 0)
				end,
			}
		)
	end
	if FiendFolio then
		LunchBox.AddPickup(FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART, -1,
			{
				CollectSound = SoundEffect.SOUND_BOSS2_BUBBLES,
				HealthAmount = 1,
				HealthKeys = { "RED_HEART" },
				AllowCandyHeartSoulLocketBonus = true,
				AllowImmaculateConception = false,
				IsHeart = true,
				OnCollect = function(player, pickup)
					player:AddBlackHearts(1)
					sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 0)
				end
			})
		LunchBox.AddPickup(FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART, -1,
			{
				CollectSound = SoundEffect.SOUND_BOSS2_BUBBLES,
				HealthAmount = 1,
				HealthKeys = { "RED_HEART" },
				AllowCandyHeartSoulLocketBonus = true,
				AllowImmaculateConception = false,
				IsHeart = true,
				OnCollect = function(player, pickup)
					if CustomHealthAPI.Helper.CanPickKey(player, "IMMORAL_HEART") then
						CustomHealthAPI.Library.AddHealth(player, "IMMORAL_HEART", 1, true)
						sfx:Play(FiendFolio.Sounds.FiendHeartPickup, 1, 0, false, 1)
					end
				end
			})
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

CustomHealthAPI.Library.AddCallback("RestoredCollection", CustomHealthAPI.Enums.Callbacks.CAN_PICK_HEALTH, 0,
	function(player, key)
		if DoesLunchBoxNeedsCharge(player) then
			local typ = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
			if typ == CustomHealthAPI.Enums.HealthTypes.RED then
				return true
			end
		end
	end)

CustomHealthAPI.Library.AddCallback("RestoredCollection", CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, 0,
	function(player, key, hp)
		local data = Helpers.GetData(player)
		if data.AddToLunchBox then
			local typ = CustomHealthAPI.Library.GetInfoOfKey(key, "Type")
			if typ == CustomHealthAPI.Enums.HealthTypes.RED then
				hp = HPLeft(player, math.max(hp, data.AddToLunchBox))
			end
		end
		data.AddToLunchBox = nil
		return key, hp
	end)


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
			player:SetActiveCharge(Helpers.GetCharge(player, slot) - itemConfig:GetCollectible(collectible).MaxCharges)
		else
			if collectible == RepentogonTargetCol then
				remove = true
			else
				player:AddCollectible(collectible - 1, 0, false, slot)
			end
		end
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

RestoredCollection:AddPriorityCallback(
	ModCallbacks.MC_PRE_PICKUP_COLLISION,
	CallbackPriority.IMPORTANT,
	function(_, pickup, collider, low)
		if collider.Type == EntityType.ENTITY_PLAYER and collider.Variant == 0 then
			local player = collider:ToPlayer()
			if not DoesLunchBoxNeedsCharge(player) then
				return
			end
			local data = Helpers.GetData(player)

			local lunchBoxData = LunchBox.GetPickupData(pickup.Variant, pickup.SubType) or
				LunchBox.GetPickupData(pickup.Variant, -1)
			if lunchBoxData == nil then
				lunchBoxData = CustomHealthAPI.Library.GetPickupDefinition(pickup.Variant, pickup.SubType) or CustomHealthAPI.Library.GetPickupDefinition(pickup.Variant, -1)
			end
			if lunchBoxData ~= nil then
				data.AddToLunchBox = (#lunchBoxData.HealthKeys == 1 and CustomHealthAPI.Library.GetInfoOfKey(lunchBoxData.HealthKeys[1], "Type") ==
					CustomHealthAPI.Enums.HealthTypes.RED) and lunchBoxData.HealthAmount or 1
				local canCollect = CustomHealthAPI.Helper.CanCollectCustomPickup(player, pickup, lunchBoxData)
				if canCollect then
					local chapiResult = CustomHealthAPI.Helper.CustomPickupCollision(pickup, player, lunchBoxData)
					if chapiResult ~= nil then
						if ModCallbacks.MC_POST_PICKUP_COLLISION then
							Isaac.RunCallbackWithParam(ModCallbacks.MC_POST_PICKUP_COLLISION, pickup.Variant, pickup,
								collider, low)
						end
						return chapiResult
					end
				end
			end
		end
	end
)
