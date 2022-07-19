int originalGameMode;
int originalGameType;

public ConfigureShield() {
	originalGameMode = GetConVarInt(game_mode);
	originalGameType = GetConVarInt(game_type);
	
	SetConVarInt(game_mode, 0, true, false);
	SetConVarInt(game_type, 0, true, false);
}

public ResetShield() {
	SetConVarInt(game_mode, originalGameMode, true, false);
	SetConVarInt(game_type, originalGameType, true, false);
}
