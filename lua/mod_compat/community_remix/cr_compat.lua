RestoredCollection:AddModCompat(function()
	return communityRemix and EID
end, function()
	EID:assignTransformation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD, "Max")
	EID:assignTransformation(
		"collectible",
		RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC,
		"Tammy"
	)
end)
