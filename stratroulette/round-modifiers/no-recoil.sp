public ConfigureNoRecoil() {
	if (weapon_accuracy_nospread != INVALID_HANDLE) {
		SetConVarInt(weapon_accuracy_nospread, 1, true, false);
		SetConVarInt(weapon_recoil_cooldown, 0, true, false);
		SetConVarInt(weapon_recoil_decay1_exp, 99999, true, false);
		SetConVarInt(weapon_recoil_decay2_exp, 99999, true, false);
		SetConVarInt(weapon_recoil_decay2_lin, 99999, true, false);
		SetConVarInt(weapon_recoil_scale, 0, true, false);
		SetConVarInt(weapon_recoil_suppression_shots, 500, true, false);
	}
}

public ResetNoRecoil() {
	SetConVarInt(weapon_accuracy_nospread, 0, true, false);
	SetConVarFloat(weapon_recoil_cooldown, 0.55, true, false);
	SetConVarFloat(weapon_recoil_decay1_exp, 3.5, true, false);
	SetConVarInt(weapon_recoil_decay2_exp, 8, true, false);
	SetConVarInt(weapon_recoil_decay2_lin, 18, true, false);
	SetConVarInt(weapon_recoil_scale, 2, true, false);
	SetConVarInt(weapon_recoil_suppression_shots, 4, true, false);
}
