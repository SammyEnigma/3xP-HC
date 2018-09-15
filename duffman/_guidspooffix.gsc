init(x) {
	while(1) {
		level waittill("connected",player);
		player thread GuidspooferFix();
	}
} 

GuidspooferFix() {
	self endon("disconnect");
	wait 3; // using a long wait because of adminmod
	guid = self getGuid();
	if(!isDefined(guid) || guid.size < 32)
		return;
	stat_start = 800;
	//getting current stats
	currentstats = [];
	for(i=0;i<4;i++)
		currentstats[currentstats.size] = self getStat(stat_start+i);
	//waittill my other guidspoofer fix ban them for Fakeguids
	guid = getSubStr(guid,24,32);
	abc = "abcdef";
	guidsum = "";
	for(i=0;i<guid.size;i++) {
		foundletter = false;
		for(k=0;k<abc.size && !foundletter;k++) {
			if(guid[i] == abc[k]) {
				guidsum += k;
				foundletter = true;
			}
		}
		if(!foundletter)
			guidsum += guid[i];
	}
	stat = [];
	for(i=0;i<guidsum.size;i+=2)
		stat[stat.size] = int(guidsum[i] + guidsum[i+1]);
	stat_need_set = false;
	for(i=0;i<currentstats.size && !stat_need_set;i++)
		if(currentstats[i] == 0)
			stat_need_set = true;
	if(stat_need_set || !self duffman\_common::hasPermission("spoof_protected"))
		for(i=0;i<4;i++) 
			self setStat(stat_start+i,stat[i]);
	else {
		for(i=0;i<currentstats.size;i++) {
			if(currentstats[i] != stat[i]) {
				self duffman\_common::dropPlayer("kick","Guidspoofer ("+guid+")");
				return;
			}
		}
	}
}