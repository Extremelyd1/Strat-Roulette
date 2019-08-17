public ConfigureGravity(char gravity[500]) {
	new newPlayerGravity = StringToInt(gravity);

	SetConVarInt(sv_gravity, newPlayerGravity, true, false);
}

public ResetGravity() {
	SetConVarInt(sv_gravity, 800, true, false);
}
