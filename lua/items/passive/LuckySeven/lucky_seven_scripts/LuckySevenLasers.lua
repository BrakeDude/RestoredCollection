local LuckySevenLasers = {}
local Helpers = RestoredCollection.Helpers

---@param laser EntityLaser
function LuckySevenLasers:OnLaserInit(laser)
	if laser.SubType == 1 then
		return
	end
	if laser.SpawnerType ~= EntityType.ENTITY_PLAYER and not laser.Parent then
		return
	end

	local player = laser.SpawnerEntity:ToPlayer()

	if not player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then
		return
	end

	local laserData = Helpers.GetData(laser)

	local rng = RNG()
	rng:SetSeed(laser.InitSeed, 35)

	local chance = Helpers.GetLuckySevenChance(player)
	if rng:RandomInt(100) <= chance then
		laserData.IsLuckySevenLaser = true
		laser.CollisionDamage = laser.CollisionDamage * Helpers.GetLuckySevenDamageMult(player)
	end
end
RestoredCollection:AddCallback(
	REPENTOGON and ModCallbacks.MC_POST_FIRE_TECH_LASER or ModCallbacks.MC_POST_LASER_INIT,
	LuckySevenLasers.OnLaserInit
)

local BrimLookUp = {
	[1] = true,
	[3] = true,
	[6] = true,
	[9] = true,
	[11] = true,
	[14] = true,
	[15] = true,
}

---@param laser EntityLaser
local function IsBrimLaser(laser)
	return BrimLookUp[laser.Variant]
end

---@param laser EntityLaser
function LuckySevenLasers:UpdateLaser(laser)
	if BrimLookUp[laser.Variant] or laser.SubType ~= LaserSubType.LASER_SUBTYPE_RING_LUDOVICO then
		local data = Helpers.GetData(laser)
		if data.LuckyLaserUpdate then
			data.LuckyLaserUpdate = nil
			return
		end
		local player = Helpers.GetPlayerFromTear(laser)
		if player == nil then
			return
		end
		if not player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then
			return
		end
		local rng = laser:GetDropRNG()
		local chance = Helpers.GetLuckySevenChance(player)
		if not data.LuckySevenLaserCountdown or data.LuckySevenLaserCountdown <= 0 then
			if rng:RandomInt(500) <= chance then
				data.IsLuckySevenLaser = true
				data.LuckySevenLaserCountdown = 4
			else
				data.IsLuckySevenLaser = nil
			end
		elseif data.LuckySevenLaserCountdown and data.LuckySevenLaserCountdown > 0 then
			data.LuckySevenLaserCountdown = data.LuckySevenLaserCountdown - 1
		end
		if data.IsLuckySevenLaser then
			laser.CollisionDamage = laser.CollisionDamage * Helpers.GetLuckySevenDamageMult(player)
			data.LuckyLaserUpdate = true
			laser:Update()
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, LuckySevenLasers.UpdateLaser)

---@param laser EntityLaser
function LuckySevenLasers:OnLaserRender(laser)
	if BrimLookUp[laser.Variant] then
		return
	end
	local laserData = Helpers.GetData(laser)
	if not laserData.IsLuckySevenLaser then
		return
	end

	local color = Color(1, 1, 1, 1, 252 / 255, 210 / 255, 83 / 255)
	laser.Color = color
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, LuckySevenLasers.OnLaserRender)

---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
function LuckySevenLasers:OnEntityDamage(entity, damage, flags, source)
	if not Helpers.IsTargetableEnemy(entity) or entity.HitPoints > damage then
		return
	end
	if source.Type ~= EntityType.ENTITY_PLAYER then
		return
	end
	local player = source.Entity:ToPlayer()
	if not player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then
		return
	end
	if flags & DamageFlag.DAMAGE_LASER == 0 then
		return
	end

	for _, laser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
		laser = laser:ToLaser()
		local laserData = Helpers.GetData(laser)
		if
			Helpers.DoesLaserHitEntity(laser, entity) and laserData.IsLuckySevenLaser
			or laserData.IsLuckySevenLudoLaser
		then
			local rng = RNG()
			rng:SetSeed(laser.InitSeed, 35)
			Helpers.TurnEnemyIntoGoldenMachine(entity, player, rng)
			break
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LuckySevenLasers.OnEntityDamage)
