public ConfigureInfiniteAmmo(char infiniteAmmoType[500]) {
	if (StrEqual(infiniteAmmoType, "1") || StrEqual(infiniteAmmoType, "2")) {
		new ammoInt = StringToInt(infiniteAmmoType);
		SetConVarInt(sv_infinite_ammo, ammoInt, true, false);
	}
}

public ResetInfiniteAmmo() {
	SetConVarInt(sv_infinite_ammo, 0, true, false);
}
