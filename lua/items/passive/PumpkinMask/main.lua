local PumpkinMask = {}
local Helpers = include("lua.helpers.Helpers")

---@param player EntityPlayer
---@return boolean
local function Can360Degree(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
end

---@param position Vector
---@param shootDir Vector
---@param damage number
---@param parent Entity?
local function ShootPumkinSeed(position, shootDir, damage, parent)
	local tear = Isaac.Spawn(
		EntityType.ENTITY_TEAR,
		RestoredCollection.Enums.TearVariant.PUMPKIN_SEED,
		0,
		position,
		shootDir,
		parent
	):ToTear()
	tear.CollisionDamage = damage
	local sprite = tear:GetSprite()
	sprite:Play(sprite:GetDefaultAnimation(), true)
end

local function FamiliarShootSeeds(familiarVariant, player, shootVec, damage, modifier, canShoot)
	if not canShoot then
		return
	end
	local familiars = TSIL.Utils.Tables.Filter(
		Isaac.FindByType(EntityType.ENTITY_FAMILIAR, familiarVariant, -1, true, false),
		function(_, ent)
			ent = ent:ToFamiliar()
			return ent.Player and GetPtrHash(ent.Player) == GetPtrHash(player)
		end
	)
	if #familiars == 0 then
		return
	end
	for i = 0, TSIL.Random.GetRandomInt(3 + modifier, 5 + modifier) do
		TSIL.Utils.Tables.ForEach(familiars, function(_, familiar)
			local twistedPair = familiar:ToFamiliar()
			Helpers.scheduleForUpdate(function()
				ShootPumkinSeed(
					twistedPair.Position,
					shootVec:Rotated(TSIL.Random.GetRandomInt(-15, 15)) * player.ShotSpeed,
					damage,
					player
				)
			end, 2 * i)
		end)
	end
end

---@param player EntityPlayer
function PumpkinMask:FireSeeds(player)
	local numPumpkins = player:GetCollectibleNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK)
	if numPumpkins > 0 and not player:IsDead() then
		local data = Helpers.GetData(player)
		if not data.FireDelaySeeds then
			data.FireDelaySeeds = -1
		end
		data.FireDelaySeeds = math.max(-1, data.FireDelaySeeds - 1)
		if data.FireDelaySeeds < 0 and player:GetItemState() == 0 then
			if player:GetFireDirection() ~= Direction.NO_DIRECTION then
				local shootVec = Helpers.GetVectorFromDirection(player:GetHeadDirection())
				if Can360Degree(player) then
					shootVec = player:GetAimDirection()
				end
				shootVec = shootVec:Resized(9) + player:GetTearMovementInheritance(shootVec)
				local numPumpkinNumModifier = 2 * (numPumpkins - 1)
				local damage = player.Damage * 0.4
				local mult = 1
				if not Helpers.IsAnyPlayerType(player, PlayerType.PLAYER_LILITH, PlayerType.PLAYER_LILITH_B) then
					mult = 0.75
				end

				if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					mult = mult + 1
				end

				mult = mult + 0.25 * player:GetTrinketMultiplier(TrinketType.TRINKET_CHILD_LEASH)
				if player:CanShoot() then
					for i = 0, TSIL.Random.GetRandomInt(3 + numPumpkinNumModifier, 5 + numPumpkinNumModifier) do
						Helpers.scheduleForUpdate(function()
							if not player:IsDead() then
								ShootPumkinSeed(
									player.Position + player.TearsOffset,
									shootVec:Rotated(TSIL.Random.GetRandomInt(-15, 15)) * player.ShotSpeed,
									player.Damage * 0.4,
									player
								)
							end
						end, 2 * i)
					end
				end
				FamiliarShootSeeds(FamiliarVariant.INCUBUS, player, shootVec, damage * mult, numPumpkinNumModifier, true)
				FamiliarShootSeeds(FamiliarVariant.UMBILICAL_BABY, player, shootVec, damage * mult, numPumpkinNumModifier, true)
				FamiliarShootSeeds(FamiliarVariant.TWISTED_BABY, player, shootVec, damage * mult / 2, numPumpkinNumModifier, true)
				data.FireDelaySeeds = Helpers.ToMaxFireDelay(2 / (2 + numPumpkins))
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PumpkinMask.FireSeeds, 0)

---@param tear EntityTear
function PumpkinMask:SeedUpdate(tear)
	tear.SpriteRotation = tear.Velocity:GetAngleDegrees() + 90
end
RestoredCollection:AddCallback(
	ModCallbacks.MC_POST_TEAR_UPDATE,
	PumpkinMask.SeedUpdate,
	RestoredCollection.Enums.TearVariant.PUMPKIN_SEED
)

---From FiendFolio
---@param tear Entity
function PumpkinMask:PostSeedRemove(tear)
	if tear.Variant == RestoredCollection.Enums.TearVariant.PUMPKIN_SEED then
		local splat = Isaac.Spawn(
			EntityType.ENTITY_EFFECT,
			RestoredCollection.Enums.Entities.PUMPKIN_SEED_SHATTER.Variant,
			0,
			tear.Position,
			Vector.Zero,
			tear
		):ToEffect()
		splat:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		splat.PositionOffset = tear.PositionOffset
		splat.SpriteOffset = tear.SpriteOffset
		tear = tear:ToTear()
		splat.SpriteScale = Vector(tear.Scale, tear.Scale) / 2
		splat:Update()
		RestoredCollection.SFX:Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PumpkinMask.PostSeedRemove, EntityType.ENTITY_TEAR)

---@param effect EntityEffect
function PumpkinMask:SeedPoofRemoval(effect)
	if effect:GetSprite():IsFinished() then
		effect:Remove()
	end
end
RestoredCollection:AddCallback(
	ModCallbacks.MC_POST_EFFECT_UPDATE,
	PumpkinMask.SeedPoofRemoval,
	RestoredCollection.Enums.Entities.PUMPKIN_SEED_SHATTER.Variant
)

RestoredCollection:AddCallback("ON_EDITH_STOMP", function(_, player, stompDamage, bombLanding, forced, isStompPool)
	local numPumpkins = player:GetCollectibleNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK)
	for i = 0, TSIL.Random.GetRandomInt(3 * numPumpkins, 5 * numPumpkins) do
		Helpers.scheduleForUpdate(function()
			local shootVec = Vector.FromAngle(TSIL.Random.GetRandomInt(1, 360)):Resized(9) * player.ShotSpeed
			if not player:IsDead() then
				ShootPumkinSeed(player.Position + player.TearsOffset, shootVec, player.Damage * 0.4, player)
			end
		end, 2 * i)
	end
end, { Item = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK })
