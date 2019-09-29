public ConfigureSlowMotion() {
	SetConVarInt(sv_cheats, 1, true, false);
	CreateTimer(0.1, SlowMotionTimer);
}

public ResetSlowMotion() {
	SetConVarInt(sv_cheats, 0, true, false);
	SetConVarFloat(host_timescale, 1.0, true, false);
}

public Action:SlowMotionTimer(Handle timer) {
	SetConVarFloat(host_timescale, 0.5, true, false);
}
