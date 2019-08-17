public ConfigureNoFriction() {
	SetConVarInt(sv_friction, -1, true, false);
}

public ResetNoFriction() {
	SetConVarFloat(sv_friction, 5.2, true, false);
}
