bool noKnife = false;

ConfigureNoKnife() {
	SetKnife(false);

	noKnife = true;
}

ResetNoKnife() {
	SetKnife(true);

	noKnife = false;
}
