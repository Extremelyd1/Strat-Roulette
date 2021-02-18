#undef REQUIRE_PLUGIN
#include "include/pugsetup.inc"
#define REQUIRE_PLUGIN

public bool IsPugSetupMatchLive() {
	if (pugSetupLoaded) {
		return PugSetup_IsMatchLive();
	}
	return false;
}
