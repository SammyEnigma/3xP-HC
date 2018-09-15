getPermissions() {
	permission = [];
	// ** set the permissions for each group here
	//    seperate them with , 

	// ** To add a player as admin etc. use 'set admin einloggen:PID:ADMINRANK'

	permission["master"] = "*";
	permission["senior"] = "spectate_all,dvartweaks,3xP-Member,spoof_protected,balance";
	permission["member"] = "spectate_all,dvartweaks,3xP-Member,spoof_protected,balance";
	permission["trial"] = "spectate_all,dvartweaks,3xP-Member,spoof_protected,balance";
	permission["friend"] = "spectate_all,dvartweaks,balance";
	permission["vip2"] = "dvartweaks,balance";
	permission["vip"] = "dvartweaks,balance";
	permission["trusted"] = "spectate_all,dvartweaks,balance";
	permission["default"] = "";
	return permission;
}