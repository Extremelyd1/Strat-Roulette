public ConfigureBhop() {
	SetConVarInt(sv_autobunnyhopping, 1, true, false);
	SetConVarInt(sv_enablebunnyhopping, 1, true, false);
	SetConVarInt(sv_maxvelocity, 9000, true, false);
	SetConVarInt(sv_airaccelerate, 12000, true, false);
}

public ResetBhop() {
	SetConVarInt(sv_autobunnyhopping, 0, true, false);
	SetConVarInt(sv_enablebunnyhopping, 0, true, false);
	SetConVarInt(sv_maxvelocity, 3500, true, false);
	SetConVarInt(sv_airaccelerate, 12, true, false);
}
