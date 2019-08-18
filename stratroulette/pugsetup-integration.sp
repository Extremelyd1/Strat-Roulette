#if defined _pugsetup_included
#include "include/pugsetup.inc"
#endif

public bool IsPugSetupMatchLive() {
#if defined _pugsetup_included
	return PugSetup_IsMatchLive();
#endif
	return false;
}
