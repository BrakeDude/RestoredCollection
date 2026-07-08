local DiceBombsLocal = {}
local Helpers = RestoredCollection.Helpers

local DiceBombItemBlacklist = {
	[CollectibleType.COLLECTIBLE_POLAROID] = true,
	[CollectibleType.COLLECTIBLE_NEGATIVE] = true,
	[CollectibleType.COLLECTIBLE_DADS_NOTE] = true,
	[CollectibleType.COLLECTIBLE_NULL] = true,
}

local DiceBombPickupBlacklist = {
	[PickupVariant.PICKUP_BED] = true,
	[PickupVariant.PICKUP_BIGCHEST] = true,
	[PickupVariant.PICKUP_MOMSCHEST] = true,
	[PickupVariant.PICKUP_SHOPITEM] = true,
	[PickupVariant.PICKUP_THROWABLEBOMB] = true,
	[PickupVariant.PICKUP_TROPHY] = true,
	[PickupVariant.PICKUP_COLLECTIBLE] = true,
	[PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
}

local function ChangeSprite(bomb)
	local sprite = bomb:GetSprite()
	local file = sprite:GetFilename()
	Helpers.ChangeBombSprite(bomb, "gfx/items/pick ups/bombs/dice" .. file:sub(file:len() - 5))
end

function DiceBombsLocal:D1BombExplode(rng, position, player, radius)
	local pickup
	for i, entity in ipairs(Isaac.FindInRadius(position, radius)) do
		if entity.Type == EntityType.ENTITY_PICKUP and not DiceBombPickupBlacklist[entity.Variant] then
			pickup = entity
		end
	end
	if pickup then
		if pickup.Variant ~= PickupVariant.PICKUP_BOMB then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup.Variant, 0, position, Vector.Zero, nil)
		else
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_BOMB,
				BombSubType.BOMB_NORMAL,
				position,
				Vector.Zero,
				nil
			)
		end
	end
	return true
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D1BombExplode,
	CollectibleType.COLLECTIBLE_D1
)

function DiceBombsLocal:D4BombExplode(rng, position, player, radius)
	local itemConf = Isaac.GetItemConfig()
		:GetCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)
	if REPENTOGON then
		itemConf.Tags = itemConf.Tags | ItemConfig.TAG_QUEST
	end

	for i, entity in ipairs(Isaac.FindInRadius(position, radius)) do
		if entity.Type == EntityType.ENTITY_PLAYER and entity.Variant == 0 then
			entity:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D4, 1)
		end
	end

	if REPENTOGON then
		itemConf.Tags = itemConf.Tags & ~ItemConfig.TAG_QUEST
	end

	return true
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D4BombExplode,
	CollectibleType.COLLECTIBLE_D4
)

function DiceBombsLocal:D6BombExplode(rng, position, player, radius)
	for i, entity in ipairs(Isaac.FindInRadius(position, radius)) do
		if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
			if not DiceBombItemBlacklist[entity.SubType] then
				if rng:RandomInt(20) > 0 then
					local itemPool = RestoredCollection.Game:GetItemPool()
					local poolType = itemPool:GetPoolForRoom(RestoredCollection.Room():GetType(), entity.InitSeed)
					local col = itemPool:GetCollectible(poolType, true)
					entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, col, true)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
				else
					entity:Remove()
					RestoredCollection.Game:SpawnParticles(
						entity.Position,
						EffectVariant.ROCK_PARTICLE,
						rng:RandomInt(2) + 3,
						6,
						Color(1, 1, 1, 1, 15 / 255, 15 / 255, 15 / 255),
						_,
						1
					)
					RestoredCollection.SFX:Play(SoundEffect.SOUND_MUSHROOM_POOF_2)
					RestoredCollection.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
				end
			end
		end
	end
end
--[[RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D6BombExplode,
	CollectibleType.COLLECTIBLE_D6
)]]

function DiceBombsLocal:ED6BombExplode(rng, position, player, radius)
	for i, entity in ipairs(Isaac.FindInRadius(position, radius)) do
		if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
			if not DiceBombItemBlacklist[entity.SubType] then
				if rng:RandomInt(10) > 0 then
					local itemPool = RestoredCollection.Game:GetItemPool()
					local poolType = itemPool:GetPoolForRoom(RestoredCollection.Room():GetType(), entity.InitSeed)
					local col = itemPool:GetCollectible(poolType, true)
					entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, col, true)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
				else
					entity:Remove()
					RestoredCollection.Game:SpawnParticles(
						entity.Position,
						EffectVariant.ROCK_PARTICLE,
						rng:RandomInt(2) + 3,
						6,
						Color(1, 1, 1, 1, 15 / 255, 15 / 255, 15 / 255),
						_,
						1
					)
					RestoredCollection.SFX:Play(SoundEffect.SOUND_MUSHROOM_POOF_2)
					RestoredCollection.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
				end
			end
		end
	end
	return false
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.ED6BombExplode,
	CollectibleType.COLLECTIBLE_ETERNAL_D6
)

---@param rng any
---@param position any
---@param player EntityPlayer
---@param radius any
---@return boolean
function DiceBombsLocal:D7BombExplode(rng, position, player, radius)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM)
	return true
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D7BombExplode,
	CollectibleType.COLLECTIBLE_D7
)

function DiceBombsLocal:D8BombExplode(rng, position, player, radius)
	for i, entity in ipairs(Isaac.FindInRadius(position, radius)) do
		if entity.Type == EntityType.ENTITY_PLAYER and entity.Variant == 0 then
			entity:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D8, 1)
		end
	end
	return true
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D8BombExplode,
	CollectibleType.COLLECTIBLE_D8
)

---@param rng any
---@param position any
---@param player EntityPlayer
---@param radius any
---@return boolean
function DiceBombsLocal:D10BombExplode(rng, position, player, radius)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D10, UseFlag.USE_NOANIM)
	return true
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D10BombExplode,
	CollectibleType.COLLECTIBLE_D10
)

---@param rng any
---@param position any
---@param player EntityPlayer
---@param radius any
---@return boolean
function DiceBombsLocal:D12BombExplode(rng, position, player, radius)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D12, UseFlag.USE_NOANIM)
	return true
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D12BombExplode,
	CollectibleType.COLLECTIBLE_D12
)

function DiceBombsLocal:D20BombExplode(rng, position, player, radius)
	for i, entity in ipairs(Isaac.FindInRadius(position, radius)) do
		if entity.Type == EntityType.ENTITY_PICKUP and not DiceBombPickupBlacklist[entity.Variant] then
			entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, 0, 0)
		end
	end
	return true
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.D20BombExplode,
	CollectibleType.COLLECTIBLE_D20
)

function DiceBombsLocal:SpindownBombExplode(rng, position, player, radius)
	for i, entity in ipairs(Isaac.FindInRadius(position, radius)) do
		if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
			if not DiceBombItemBlacklist[entity.SubType] then
				if rng:RandomInt(20) > 0 then
					local itemshift = entity.SubType - 1
					while true do
						if
							(
								ItemConfig.Config.IsValidCollectible(itemshift)
								and Isaac.GetItemConfig():GetCollectible(itemshift):IsAvailable()
							) or itemshift <= 1
						then
							entity
								:ToPickup()
								:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemshift, true)
							Isaac.Spawn(
								EntityType.ENTITY_EFFECT,
								EffectVariant.POOF01,
								0,
								entity.Position,
								Vector.Zero,
								nil
							)
							break
						end
						itemshift = itemshift - 1
					end
				else
					entity:Remove()
					RestoredCollection.Game:SpawnParticles(
						entity.Position,
						EffectVariant.ROCK_PARTICLE,
						rng:RandomInt(2) + 3,
						6,
						Color(1, 1, 1, 1, 15 / 255, 15 / 255, 15 / 255),
						_,
						1
					)
					RestoredCollection.SFX:Play(SoundEffect.SOUND_MUSHROOM_POOF_2)
					RestoredCollection.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
				end
			end
		end
	end
	return false
end
RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	DiceBombsLocal.SpindownBombExplode,
	CollectibleType.COLLECTIBLE_SPINDOWN_DICE
)

RestoredCollection:AddCallback(
	RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION,
	function(_, rng, position, player, radius)
		DiceBombsLocal:D1BombExplode(rng, position, player, radius)
		DiceBombsLocal:D4BombExplode(rng, position, player, radius)
		DiceBombsLocal:D8BombExplode(rng, position, player, radius)
		DiceBombsLocal:D10BombExplode(rng, position, player, radius)
		DiceBombsLocal:D12BombExplode(rng, position, player, radius)
		DiceBombsLocal:D20BombExplode(rng, position, player, radius)
		return true
	end,
	CollectibleType.COLLECTIBLE_D100
)

local function InitDiceVariant(bomb, forceDice)
	if type(forceDice) == "number" and DiceBombsAPI.GetDiceBombsSprites(forceDice) then
		Helpers.GetData(bomb).DiceBombVariant = forceDice
		return
	end
	local player = Helpers.GetPlayerFromTear(bomb)
	if not player then
		return
	end
	local data = Helpers.GetData(bomb)
	if data.DiceBombVariant then
		return
	end
	data.DiceBombVariant = CollectibleType.COLLECTIBLE_D6
	for i = 0, 3 do
		if DiceBombsAPI.GetDiceBombsSprites(player:GetActiveItem(i)) then
			data.DiceBombVariant = player:GetActiveItem(i)
			break
		end
		if REPENTOGON and player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_D_INFINITY then
			data.DiceBombVariant = CollectibleType.COLLECTIBLE_D6
			local DiceVarData = {
				[0] = CollectibleType.COLLECTIBLE_D1,
				[0x10000] = CollectibleType.COLLECTIBLE_D4,
				[0x20000] = CollectibleType.COLLECTIBLE_D6,
				[0x30000] = CollectibleType.COLLECTIBLE_ETERNAL_D6,
				[0x40000] = CollectibleType.COLLECTIBLE_D7,
				[0x50000] = CollectibleType.COLLECTIBLE_D8,
				[0x60000] = CollectibleType.COLLECTIBLE_D10,
				[0x70000] = CollectibleType.COLLECTIBLE_D12,
				[0x80000] = CollectibleType.COLLECTIBLE_D20,
				[0x90000] = CollectibleType.COLLECTIBLE_D100,
			}
			local activeItemDesc = player:GetActiveItemDesc(i)
			local dice = DiceVarData[activeItemDesc.VarData]
				or DiceVarData[activeItemDesc.VarData - player:GetActiveMinUsableCharge(i)]
			if dice then
				data.DiceBombVariant = dice
			end
			break
		end
	end
end

function DiceBombsLocal:BombInit(bomb)
	if Helpers.GetData(bomb).BombInit then
		return
	end
	local player = Helpers.GetPlayerFromTear(bomb)
	if player then
		local rng = bomb:GetDropRNG()
		local diceChance = player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)
			and (not bomb.IsFetus or bomb.IsFetus and rng:RandomInt(100) < 20)

		local nancyChance = player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
			and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 10
			and not Helpers.IsItemDisabled(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)

		if diceChance or nancyChance then
			if bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL then
				if bomb.Variant == 0 then
					bomb.Variant = RestoredCollection.Enums.BombVariant.BOMB_DICE
				end
			end
			BombFlagsAPI.AddCustomBombFlag(
				bomb,
				"DICE_BOMB",
				RestoredCollection.Enums.BombVariant.BOMB_DICE,
				InitDiceVariant,
				bomb
			)
		end
	end
end
--RestoredCollection:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, DiceBombsLocal.BombInit)

function DiceBombsLocal:DiceRocketInit(rocket)
	local player = Helpers.GetPlayerFromTear(rocket)
	if player then
		local rng = rocket:GetDropRNG()
		if
			player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)
				and rng:RandomInt(100) < 20
			or player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
				and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 5
				and not Helpers.IsItemDisabled(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)
		then
			InitDiceVariant(rocket)
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, DiceBombsLocal.DiceRocketInit, EffectVariant.ROCKET)

function DiceBombsLocal:DiceRocketExplode(rocket)
	if rocket.Type == EntityType.ENTITY_EFFECT and rocket.Variant == EffectVariant.ROCKET then
		local player = Helpers.GetPlayerFromTear(rocket)
		if not player then
			return
		end
		local data = Helpers.GetData(rocket)
		if data.DiceBombVariant then
			local callbacks = Isaac.GetCallbacks(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION)
			local d6Ran = false
			local isBomber = player:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)
			local radius = Helpers.GetBombRadiusFromDamage(20, isBomber)
			if data.DiceBombVariant ~= CollectibleType.COLLECTIBLE_D6 then
				for _, callback in ipairs(callbacks) do
					if callback.Param and callback.Param == data.DiceBombVariant then
						local ret =
							callback.Function(callback.Mod, rocket:GetDropRNG(), rocket.Position, player, radius)
						if ret ~= nil and type(ret) == "boolean" then
							if ret == true and not d6Ran then
								DiceBombsLocal:D6BombExplode(rocket:GetDropRNG(), rocket.Position, player, radius)
							end
							d6Ran = true
						end
					end
				end
			end
			if not d6Ran then
				DiceBombsLocal:D6BombExplode(rocket:GetDropRNG(), rocket.Position, player, radius)
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, DiceBombsLocal.DiceRocketExplode)

---@param bomb EntityBomb
function DiceBombsLocal:BombUpdate(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)
	if not player then
		return
	end
	local data = Helpers.GetData(bomb)

	if bomb.FrameCount == 1 then
		DiceBombsLocal:BombInit(bomb)
		if bomb.Variant == RestoredCollection.Enums.BombVariant.BOMB_DICE then
			ChangeSprite(bomb)
		end
	end

	if BombFlagsAPI.HasCustomBombFlag(bomb, "DICE_BOMB") then
		local sprite = bomb:GetSprite()
		InitDiceVariant(bomb)
		if
			bomb.Variant == RestoredCollection.Enums.BombVariant.BOMB_DICE
			and not bomb:HasTearFlags(TearFlags.TEAR_BRIMSTONE_BOMB)
		then
			local diceBombGFX = DiceBombsAPI.GetDiceBombsSprites(CollectibleType.COLLECTIBLE_D6)
			if DiceBombsAPI.GetDiceBombsSprites(data.DiceBombVariant) then
				diceBombGFX = DiceBombsAPI.GetDiceBombsSprites(data.DiceBombVariant)
			end

			if not bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
				sprite:ReplaceSpritesheet(0, diceBombGFX[1])
			else
				sprite:ReplaceSpritesheet(0, diceBombGFX[2])
			end
			sprite:LoadGraphics()
		end

		if sprite:IsPlaying("Explode") then
			local callbacks = Isaac.GetCallbacks(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION)
			local d6Ran = false
			local isBomber = player:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)
			local radius = Helpers.GetBombRadiusFromDamage(bomb.ExplosionDamage, isBomber)
			for _, callback in ipairs(callbacks) do
				if callback.Param and callback.Param == data.DiceBombVariant then
					local ret = callback.Function(callback.Mod, bomb:GetDropRNG(), bomb.Position, player, radius)
					if ret ~= nil and type(ret) == "boolean" then
						if ret == true and not d6Ran then
							DiceBombsLocal:D6BombExplode(bomb:GetDropRNG(), bomb.Position, player, radius)
						end
						d6Ran = true
					end
				end
			end
			if not d6Ran then
				DiceBombsLocal:D6BombExplode(bomb:GetDropRNG(), bomb.Position, player, radius)
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, DiceBombsLocal.BombUpdate)

RestoredCollection:AddCallback(
	"ON_EDITH_STOMP_EXPLOSION",
	function(_, player, bombDamage, position, radius, hasBombs, isGigaBomb, isScatterBomb)
		local DiceBombVariant = CollectibleType.COLLECTIBLE_D6
		for i = 0, 3 do
			if DiceBombsAPI.GetDiceBombsSprites(player:GetActiveItem(i)) then
				DiceBombVariant = player:GetActiveItem(i)
				break
			end
			if REPENTOGON and player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_D_INFINITY then
				DiceBombVariant = CollectibleType.COLLECTIBLE_D6
				local DiceVarData = {
					[0] = CollectibleType.COLLECTIBLE_D1,
					[0x10000] = CollectibleType.COLLECTIBLE_D4,
					[0x20000] = CollectibleType.COLLECTIBLE_D6,
					[0x30000] = CollectibleType.COLLECTIBLE_ETERNAL_D6,
					[0x40000] = CollectibleType.COLLECTIBLE_D7,
					[0x50000] = CollectibleType.COLLECTIBLE_D8,
					[0x60000] = CollectibleType.COLLECTIBLE_D10,
					[0x70000] = CollectibleType.COLLECTIBLE_D12,
					[0x80000] = CollectibleType.COLLECTIBLE_D20,
					[0x90000] = CollectibleType.COLLECTIBLE_D100,
				}
				local activeItemDesc = player:GetActiveItemDesc(i)
				local dice = DiceVarData[activeItemDesc.VarData]
					or DiceVarData[activeItemDesc.VarData - player:GetActiveMinUsableCharge(i)]
				if dice then
					DiceBombVariant = dice
				end
			end
		end
		local callbacks = Isaac.GetCallbacks(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION)
		local d6Ran = false
		if DiceBombVariant ~= CollectibleType.COLLECTIBLE_D6 then
			for _, callback in ipairs(callbacks) do
				if callback.Param and callback.Param == DiceBombVariant then
					local ret = callback.Function(callback.Mod, player, player, radius)
					if ret ~= nil and type(ret) == "boolean" then
						if ret == true and not d6Ran then
							DiceBombsLocal:D6BombExplode(player:GetDropRNG(), player.Position, player, radius)
						end
						d6Ran = true
					end
				end
			end
		end
		if not d6Ran then
			DiceBombsLocal:D6BombExplode(player:GetDropRNG(), player.Position, player, radius)
		end
	end,
	RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS
)

---@param position Vector
---@param forceDice CollectibleType | number?
---@param spawner Entity?
local function SpawnDiceBomb(position, forceDice, spawner)
	local bomb = Helpers.SpawnBomb(position, RestoredCollection.Enums.BombVariant.BOMB_DICE, spawner, 0, {
		["DICE_BOMB"] = {
			func = InitDiceVariant,
			args = {forceDice},
		}
	})
	ChangeSprite(bomb)
end

---@param bomb EntityBomb
---@param forceDice CollectibleType | number?
local function MakeBombDice(bomb, forceDice)
	BombFlagsAPI.AddCustomBombFlag(
		bomb,
		"DICE_BOMB",
		RestoredCollection.Enums.BombVariant.BOMB_DICE,
		InitDiceVariant,
		bomb, forceDice
	)
	ChangeSprite(bomb)
end

RestoredCollection.Bombs.DiceBombs = {
	Spawn = SpawnDiceBomb,
	AddFlagToBomb = MakeBombDice,
}
