public ConfigureBackwards() {
	SetConVarInt(sv_accelerate, -5, true, false);
	SetConVarFloat(sv_airaccelerate, -0.5, true, false);
}

public ResetBackwards() {
	SetConVarFloat(sv_accelerate, 5.5, true, false);
	SetConVarInt(sv_airaccelerate, 12, true, false);
}
