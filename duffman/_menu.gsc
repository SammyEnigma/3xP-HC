/*===================================================================||
||/|¯¯¯¯¯¯¯\///|¯¯|/////|¯¯|//|¯¯¯¯¯¯¯¯¯|//|¯¯¯¯¯¯¯¯¯|//\¯¯\/////¯¯//||
||/|  |//\  \//|  |/////|  |//|  |/////////|  |//////////\  \///  ///||
||/|  |///\  \/|  |/////|  |//|  |/////////|  |///////////\  \/  ////||
||/|  |///|  |/|  |/////|  |//|   _____|///|   _____|//////\    /////||
||/|  |////  //|  \/////|  |//|  |/////////|  |/////////////|  |/////||
||/|  |///  ////\  \////  ////|  |/////////|  |/////////////|  |/////||
||/|______ //////\_______/////|__|/////////|__|/////////////|__|/////||
||===================================================================||
||     DO NOT USE, SHARE OR MODIFY THIS FILE WITHOUT PERMISSION      ||
||===================================================================*/

init(modVersion) {
	//------------------Menu options-------------------
	//            |    Displayname   | Menu |             Function          |Arguments|Exit|Permissions
	addMenuOption("MENU_PRESTIGE","main",duffman\_prestige::LevelUp,undefined,true,"none");
	addSubMenu("MENU_EMBLEM","emblem","none");	
		addMenuOption("MENU_EMBLEM_DEFAULT","emblem",duffman\_killcard::setDesign,"default",false,"none");
		addMenuOption("MENU_EMBLEM_BLUE","emblem",duffman\_killcard::setDesign,"blue",false,"none");
		addMenuOption("MENU_EMBLEM_RED","emblem",duffman\_killcard::setDesign,"red",false,"none");
		addMenuOption("MENU_EMBLEM_GREEN","emblem",duffman\_killcard::setDesign,"green",false,"none");
		addMenuOption("MENU_EMBLEM_3XP","emblem",duffman\_killcard::setDesign,"3xp",false,"3xP-Member");
		addMenuOption("MENU_EMBLEM_OWN","emblem",::CustomEmblem,undefined,true,"none");
	addMenuOption("MENU_LASER","main",duffman\_prestige::ToggleLaser,undefined,true,"none");	
	addMenuOption("MENU_TWEAKS","main",duffman\_menu::toggleFilmTweaks,undefined,true,"none");
	addMenuOption("MENU_EDITOR","main",::ClassEditor,undefined,true,"none");
	addSubMenu("MENU_FILM","filmtweaks","none");
		addMenuOption("Crash","filmtweaks",duffman\_menu::Crash,undefined,true,"none");
		addMenuOption("Crossfire","filmtweaks",duffman\_menu::Crossfire,undefined,true,"none");
		addMenuOption("Strike","filmtweaks",duffman\_menu::Strike,undefined,true,"none");
		addMenuOption("District","filmtweaks",duffman\_menu::District,undefined,true,"none");
	addSubMenu("MENU_TWEAK","tweakables","dvartweaks");	
		addMenuOption("MENU_BRIGHT","tweakables",duffman\_menu::Tweakables,"r_fullbright",false,"none");
		addMenuOption("MENU_FOG","tweakables",duffman\_menu::Tweakables,"r_fog",false,"none");
		addMenuOption("MENU_LASER2","tweakables",duffman\_menu::Tweakables,"cg_laserforceon",false,"none");
		addMenuOption("Promod tweaks","tweakables",duffman\_menu::PromodTweaks,undefined,true,"none");
	addSubMenu("MENU_RULES","only","only");	
		addMenuOption("MENU_RESET","only",duffman\_menu::Only,"*",true,"none");
		addMenuOption("Sniper","only",duffman\_menu::Only,"m40a3_mp;remington700_mp$Sniper",true,"none");
		addMenuOption("Deagle","only",duffman\_menu::Only,"deserteaglegold_mp;deserteagle_mp$Deagle",true,"none");
		addMenuOption("Knife","only",duffman\_menu::Only,"knife_mp$Knife",true,"none");
		addMenuOption("Shotgun","only",duffman\_menu::Only,"m1014_mp;winchester1200_mp$Shotgun",true,"none");
		addMenuOption("C4","only",duffman\_menu::Only,"c4_mp$C4",true,"none");
		addMenuOption("RPG","only",duffman\_menu::Only,"rpg_mp$RPG",true,"none");
		addMenuOption("Schwebepumpe","only",duffman\_menu::Only,"schwebepumpe$Gravity Shotgun",true,"none");
	addSubMenu("MENU_DEV","dev","*");
		addMenuOption("Increase Killstreak","dev",::GiveFreeKill,undefined,false,"none");
		addMenuOption("Add Testclient(My Team)","dev",::addBot,"myteam",false,"none");
		addMenuOption("Add Testclient","dev",::addBot,"enemy",false,"none");
		addMenuOption("Add Frozenclient(My Team)","dev",::addFrozenBot,"myteam",false,"none");
		addMenuOption("Add Frozenclient","dev",::addFrozenBot,"enemy",false,"none");
		addMenuOption("Remove Testclients","dev",::removeBots,undefined,false,"none");
	addSubMenu("Language","lang","none");
		addMenuOption("Auto detect","lang",duffman\_languages::ChangeLanguage,"auto",true,"none");
		languages = GetArrayKeys(level.lang);
		for(i=0;i<languages.size;i++)
		addMenuOption(languages[i],"lang",duffman\_languages::ChangeLanguage,languages[i],true,"none");
	addMenuOption("MENU_CHANGELOG","main",::changelog,undefined,true,"none");
	//-------------------------------------------------

	duffman\_common::addConnectThread(duffman\_common::useConfig);

	thread onPlayerConnected();
	thread DvarCheck();
	level.shaders = strTok("ui_host;line_vertical;nightvision_overlay_goggles;hud_arrow_left",";");
	for(i=0;i<level.shaders.size;i++)
		precacheShader(level.shaders[i]);
}
onPlayerConnected() {
	for(;;) {
		level waittill("connected",player);
		if(!isDefined(player.pers["filmtweak"])) {
			player.pers["filmtweak"] = player duffman\_common::getCvarInt("filmtweak");
			player.pers["bright"] = player duffman\_common::getCvarInt("bright");
			player.pers["fog"] = player duffman\_common::getCvarInt("fog");
			player.pers["slow"] = player duffman\_common::getCvarInt("slow");
			player.pers["forceLaser"] = player duffman\_common::getCvarInt("laser");			
		}	
		player thread ToggleMenu();
		player thread openClickMenu();
		player thread onPlayerSpawn();
	}
}
ToggleMenu() {
	self endon("disconnect");
	while(1) {
		self waittill("night_vision_on");
		self thread endNpressTimer();
		self NpressTimer();
	}
}
NpressTimer() {
	self endon("disconnect");
	self endon("end_menu_toggle");
	self endon("night_vision_on");
	self endon("close_vip_menu");
	self waittill("night_vision_off");
	self notify("open_vip_menu");
}
endNpressTimer() {
	self endon("disconnect");
	self endon("open_vip_menu");
	wait 2;
	self notify("end_menu_toggle");
}
DvarCheck() {
	wait 6;
	while(1) {
		setDvar("menu","");
		while(getDvar("menu") == "") wait .1;
		player = duffman\_common::getPlayerByNum(int(getDvar("menu")));
		if(isDefined(player))
			player notify("open_vip_menu");
	}
}
openClickMenu() {
	self endon("disconnect");
	self.invipmenu = false;
	wait 6;
	for(;;wait .05) {
		self waittill("open_vip_menu");
		if(!self.invipmenu) {
			self.invipmenu = true;
			for(i=0;self.sessionstate == "playing" && !self isOnGround() && i < 60 || game["state"] != "playing";wait .05){i++;}
			self thread VipMenu();
			//self disableWeapons();
			if(self.health > 0) {
				wait .05;
				self.wepvip = self GetCurrentWeapon();
				self giveWeapon( "briefcase_bomb_mp" );
				self setWeaponAmmoStock( "briefcase_bomb_mp", 0 );
				self setWeaponAmmoClip( "briefcase_bomb_mp", 0 );
				wait .05;
				self switchToWeapon( "briefcase_bomb_mp" );
			}		
			self allowSpectateTeam( "allies", false );
			self allowSpectateTeam( "axis", false );
			self allowSpectateTeam( "none", false );	
		}
		else
			self endMenu();
	}
}
endMenu() {
	self notify("close_vip_menu");
	for(i=0;i<self.vipmenu.size;i++) self.vipmenu[i] thread FadeOut(1,true,"right");
	self thread Blur(2,0);
	self.vipmenubg thread FadeOut(1);
	self freezeControls(false);
	self maps\mp\gametypes\_spectating::setSpectatePermissions();	
	/*self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "freelook", true );
	self allowSpectateTeam( "none", true );*/
	if(isDefined(self.wepvip) && self.health > 0) {
		if(self.wepvip != "none")
			self switchToWeapon(self.wepvip);
		wait .05;
		self TakeWeapon("briefcase_bomb_mp");
	}
	wait 2;
	self.invipmenu = false;
}
addMenuOption(name,menu,script,args,end,permission) {
	if(!isDefined(level.menuoption)) level.menuoption["name"] = [];
	if(!isDefined(level.menuoption["name"][menu])) level.menuoption["name"][menu] = [];
	index = level.menuoption["name"][menu].size;
	level.menuoption["name"][menu][index] = name;
	level.menuoption["script"][menu][index] = script;
	level.menuoption["arguments"][menu][index] = args;
	level.menuoption["end"][menu][index] = end;
	level.menuoption["permission"][menu][index] = permission;
}
addSubMenu(displayname,name,permission) {
	addMenuOption(displayname,"main",name,"",false,permission);
}
GetMenuStuct(menu) {
	itemlist = "";
	for(i=0;i<level.menuoption["name"][menu].size;i++)  {
		if(isDefined(level.lang["EN"][level.menuoption["name"][menu][i]]))
	 		itemlist = itemlist + self duffman\_common::getLangString(level.menuoption["name"][menu][i]) + "\n";
	 	else 
	 		itemlist = itemlist + level.menuoption["name"][menu][i] + "\n";
	}
	return itemlist;
}
VipMenu() {
	self endon("close_vip_menu");
	self endon("disconnect");
	self thread Blur(0,2);
	submenu = "main";
	self.vipmenu[0] = addTextHud( self, -200, 0, .6, "left", "top", "right",0, 101 );	
	self.vipmenu[0] setShader("nightvision_overlay_goggles", 400, 650);
	self.vipmenu[0] thread FadeIn(.5,true,"right");
	self.vipmenu[1] = addTextHud( self, -200, 0, .5, "left", "top", "right", 0, 101 );	
	self.vipmenu[1] setShader("black", 400, 650);	
	self.vipmenu[1] thread FadeIn(.5,true,"right");
	self.vipmenu[2] = addTextHud( self, -200, 89, .5, "left", "top", "right", 0, 102 );		
	self.vipmenu[2] setShader("line_vertical", 600, 22);
	self.vipmenu[2] thread FadeIn(.5,true,"right");	
	self.vipmenu[3] = addTextHud( self, -190, 93, 1, "left", "top", "right", 0, 104 );		
	self.vipmenu[3] setShader("ui_host", 14, 14);			
	self.vipmenu[3] thread FadeIn(.5,true,"right");
	self.vipmenu[4] = addTextHud( self, -165, 100, 1, "left", "middle", "right", 1.4, 103 );
	self.vipmenu[4] settext(self GetMenuStuct(submenu));
	self.vipmenu[4] thread FadeIn(.5,true,"right");
	self.vipmenu[4].glowColor = (.4,.4,.4);
	self.vipmenu[4].glowAlpha = 1;
	self.vipmenu[5] = addTextHud( self, -170, 400, 1, "left", "middle", "right" ,1.4, 103 );
	self.vipmenu[5] settext(self duffman\_common::getLangString("MENU_NAVI"));	
	self.vipmenu[5] thread FadeIn(.5,true,"right");
	self.vipmenubg = addTextHud( self, 0, 0, .5, "left", "top", undefined , 0, 101 );	
	self.vipmenubg.horzAlign = "fullscreen";
	self.vipmenubg.vertAlign = "fullscreen";
	self.vipmenubg setShader("black", 640, 480);
	self.vipmenubg thread FadeIn(.2);
	wait .5;
	self freezeControls(true);	
	while(self FragButtonPressed() || self UseButtonPressed()) wait .05;
	oldads = self adsbuttonpressed();
	for(selected=0;!self meleebuttonpressed();wait .05) {
		if(self Attackbuttonpressed()) {
			if(selected == level.menuoption["name"][submenu].size-1) selected = 0;
			else selected++;	
		}
		else if(self adsbuttonpressed() != oldads) {
			if(selected == 0) selected = level.menuoption["name"][submenu].size-1;
			else selected--;
		}
		if(self adsbuttonpressed() != oldads || self Attackbuttonpressed()) {
			self playLocalSound( "mouse_over" );
			if(submenu == "main") {
				self.vipmenu[2] moveOverTime( .05 );
				self.vipmenu[2].y = 89 + (16.8 * selected);	
				self.vipmenu[3] moveOverTime( .05 );
				self.vipmenu[3].y = 93 + (16.8 * selected);	
			}
			else {
				self.vipmenu[7] moveOverTime( .05 );
				self.vipmenu[7].y = 10 + self.vipmenu[6].y + (16.8 * selected);	
			}
		}
		if(self Attackbuttonpressed() && !self useButtonPressed()) wait .15;
		if(self useButtonPressed()) {
			if(level.menuoption["permission"][submenu][selected] != "none" && !self duffman\_common::hasPermission(level.menuoption["permission"][submenu][selected])) {
				self duffman\_common::iPrintBig("NO_PERMISSION","PERMISSION",level.menuoption["permission"][submenu][selected]);
				while(self UseButtonPressed()) wait .05;
			}
			else if(!isString(level.menuoption["script"][submenu][selected])) {
				if(isDefined(level.menuoption["arguments"][submenu][selected]))
					self thread [[level.menuoption["script"][submenu][selected]]](level.menuoption["arguments"][submenu][selected]);
				else
					self thread [[level.menuoption["script"][submenu][selected]]]();
				if(level.menuoption["end"][submenu][selected])
					self thread endMenu();
				else
					while(self useButtonPressed()) wait .05;
			}
			else {
				abstand = (16.8 * selected);
				submenu = level.menuoption["script"][submenu][selected];
				self.vipmenu[6] = addTextHud( self, -430, abstand + 50, .5, "left", "top", "right", 0, 101 );	
				self.vipmenu[6] setShader("black", 200, 300);	
				self.vipmenu[6] thread FadeIn(.5,true,"left");
				self.vipmenu[7] = addTextHud( self, -430, abstand + 60, .5, "left", "top", "right", 0, 102 );		
				self.vipmenu[7] setShader("line_vertical", 200, 22);
				self.vipmenu[7] thread FadeIn(.5,true,"left");
				self.vipmenu[8] = addTextHud( self, -219, 93 + (16.8 * selected), 1, "left", "top", "right", 0, 104 );		
				self.vipmenu[8] setShader("hud_arrow_left", 14, 14);			
				self.vipmenu[8] thread FadeIn(.5,true,"left");
				self.vipmenu[9] = addTextHud( self, -420, abstand + 71, 1, "left", "middle", "right", 1.4, 103 );
				self.vipmenu[9] settext(self GetMenuStuct(submenu));
				self.vipmenu[9] thread FadeIn(.5,true,"left");
				self.vipmenu[9].glowColor = (.4,.4,.4);
				self.vipmenu[9].glowAlpha = 1;
				selected = 0;
				wait .2;
			}
		}
		oldads = self adsbuttonpressed();
	}
	self thread endMenu();
}
addTextHud( who, x, y, alpha, alignX, alignY, vert, fontScale, sort ) { //stealed braxis function like a boss xD
	if( isPlayer( who ) ) hud = newClientHudElem( who );
	else hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.horzAlign = vert;
	if(fontScale != 0)
		hud.fontScale = fontScale;
	hud.archived = false;
	return hud;
}
FadeOut(time,slide,dir) {	
	if(!isDefined(self)) return;
	if(isdefined(slide) && slide) {
		self MoveOverTime(0.2);
		if(isDefined(dir) && dir == "right") self.x+=600;
		else self.x-=600;
	}
	self fadeovertime(time);
	self.alpha = 0;
	wait time;
	if(isDefined(self)) self destroy();
}
FadeIn(time,slide,dir) {
	if(!isDefined(self)) return;
	if(isdefined(slide) && slide) {
		if(isDefined(dir) && dir == "right") self.x+=600;
		else self.x-=600;	
		self moveOverTime( .2 );
		if(isDefined(dir) && dir == "right") self.x-=600;
		else self.x+=600;
	}
	alpha = self.alpha;
	self.alpha = 0;
	self fadeovertime(time);
	self.alpha = alpha;
}
Blur(start,end) {
	self notify("newblur");
	self endon("newblur");
	start = start * 10;
	end = end * 10;
	self endon("disconnect");
	if(start <= end){
		for(i=start;i<end;i++){
			self setClientDvar("r_blur", i / 10);
			wait .05;
		}
	}
	else for(i=start;i>=end;i--){
		self setClientDvar("r_blur", i / 10);
		wait .05;
	}
}
//--------------------Menu script functions-------------------
toggleFilmTweaks(x) {
	if(!self duffman\_common::getCvarInt("filmtweak")) {
		self setClientDvar("r_filmusetweaks",1);
		self setClientDvar("r_filmtweakenable",1);
		self iPrintln("^5Filmtweaks enabled!");
		self duffman\_common::setCvar("filmtweak","1");
		self.pers["filmtweak"] = 1;
	}
	else {
		self setClientDvar("r_filmusetweaks",0);
		self setClientDvar("r_filmtweakenable",0);
		self duffman\_common::setCvar("filmtweak","0");
		self iPrintln("^5Filmtweaks disabled!");
		self.pers["filmtweak"] = 0;
	}
}

Crash(x) {
	self setClientDvars("r_filmtweakContrast","1.5","r_filmtweakLighttint","0.85 0.85 0.98","r_filmtweakDarktint","1.24 1.44 1.9","r_filmtweakDesaturation","0","r_filmtweakbrightness","0.1");
}

District(x) {
	self setClientDvars("r_filmtweakLighttint","0.9 0.9 1","r_filmtweakDarktint","1.4 1.6 1.8","r_filmtweakbrightness","0.1");
}

Strike(x) {
	self setClientDvars("r_filmtweakContrast","1.450","r_filmtweakLighttint","1.1 1.1 1.6","r_filmtweakDarktint","1.5 1.6 2","r_filmtweakDesaturation","0","r_filmtweakbrightness","0.1");
}

Crossfire(x) {
	self setClientDvars("r_filmtweakContrast","1.450","r_filmtweakLighttint","0.95 1 1.05","r_filmtweakDarktint","1.505 1.63505 2","r_filmtweakDesaturation","0","r_filmtweakbrightness","0.1255");
}

WantAServer(x) {
	self endon("disconnect");
	oldads = self adsbuttonpressed();
	shader = [];
	for(i=0;i<4;i++) {
		shader[i] = addTextHud( self, -100, 0, .6, "center", "middle", "center",1.6, 101 + i );	
	  	shader[i].vertAlign = "middle";
	  	shader[i] thread FadeIn(.5);
	}
	shader[0] SetShader("white",402,202);
	shader[1] SetShader("black",400,200);
	shader[2].alpha = 1;
	shader[2].y = -105;
	shader[2].alignX = "left";
	shader[2].x = -260;
	shader[2] setText(" \n^53xP' ^7Hosting\n \nYou ever wanted to have your own CoD4 server?\nThen we could help you!\nWe offer cheap CoD4 servers to finace the cost\nof our Rootserver. Prizes starting at 8 euro.");
	shader[3].alpha = 1;
	shader[3].y = -8;
	shader[3].alignX = "left";
	shader[3].x = -260;
	shader[3] setText(" \n \nThe servers can be either the same as ours\nor your complete own mod.\n \nIf you are interested PM in xF: mirko911");
	while(self useButtonPressed()) wait .05;
	while(!self AttackButtonPressed() && oldads == self adsbuttonpressed() && !self MeleeButtonPressed() && !self useButtonPressed() && self.invipmenu) wait .05;
	for(i=0;i<4;i++)
		shader[i] thread FadeOut(1,true,"left");
}

Tweakables(dvar) {
	name["r_fullbright"] = "Fullbright";//0
	name["cg_laserforceon"] = "Laser";//0
	name["r_fog"] = "Fog";//1
	name["jump_slowdownEnable"] = "Jump Slowdown";//1

	if(dvar == "r_fullbright") {
		if( self.pers["bright"] ) {
			self duffman\_common::setCvar("bright","0");
			self.pers["bright"] = 0;
			self iPrintlnbold(name[dvar] + " ^5off!");
			self setClientDvar(dvar,0);
		}
		else {
			self duffman\_common::setCvar("bright","1");
			self iPrintlnbold(name[dvar] + " ^5on!");
			self.pers["bright"] = 1;
			self setClientDvar(dvar,1);
		}
	}
	else if(dvar == "cg_laserforceon") {
		if(self.pers["forceLaser"]) {
			self duffman\_common::setCvar("laser","0");
			self.pers["forceLaser"] = 0;
			self iPrintlnbold(name[dvar] + " ^5off!");
			self setClientDvar(dvar,0);
		}
		else {
			self duffman\_common::setCvar("laser","1");
			self.pers["forceLaser"] = 1;
			self iPrintlnbold(name[dvar] + " ^5on!");
			self setClientDvar(dvar,1);
		}
	}
	else if(dvar == "r_fog") {
		if(self.pers["fog"]) {
			self duffman\_common::setCvar("fog","0");
			self.pers["fog"] = 0;
			self iPrintlnbold(name[dvar] + " ^5off!");
			self setClientDvar(dvar,0);
		}
		else {
			self duffman\_common::setCvar("fog","1");
			self iPrintlnbold(name[dvar] + " ^5on!");
			self setClientDvar(dvar,1);
			self.pers["fog"] = 1;
		}
	}
	else if(dvar == "jump_slowdownEnable") {
		if(self.pers["slow"]) {
			self duffman\_common::setCvar("slow","0");
			self iPrintlnbold(name[dvar] + " ^5off!");
			self setClientDvar(dvar,0);
			self.pers["slow"] = 0;
		}
		else {
			self duffman\_common::setCvar("slow","1");
			self iPrintlnbold(name[dvar] + " ^5on!");
			self setClientDvar(dvar,1);
			self.pers["slow"] = 1;
		}
	}	
}

Only(wep) {
	game["only_weapon"] = strTok(wep,"$")[0];
	players = duffman\_common::getAllPlayers();
	for(i=0;i<players.size;i++) 
		players[i] notify("new_only_weapon");
	if(strTok(wep,"$")[0] == "schwebepumpe") {
		game["only_welcomemsg"] = strTok(wep,"$")[1];
		level duffman\_common::iPrintBig("ONLY_CHANGED","MODE",game["only_welcomemsg"]);
		game["only_weapons"] = "m1014_mp;winchester1200_mp";
	}
	else if(strTok(wep,"$")[0] != "*") {
		game["only_welcomemsg"] = strTok(wep,"$")[1];
		level duffman\_common::iPrintBig("ONLY_CHANGED","MODE",game["only_welcomemsg"]);
		game["only_weapons"] = strTok(wep,"$")[0];
	}
	else {
		level duffman\_common::iPrintBig("ONLY_RESETED");
		game["only_welcomemsg"] = undefined;
		game["only_weapons"] = undefined;
	}
}

onPlayerSpawn() {
	self endon("disconnect");
	while(1) {
		self common_scripts\utility::waittill_any("disconnect","spawned","new_only_weapon");
		if(!isDefined(self.pers["welcomed_only"])) {
			self.pers["welcomed_only"] = 1;
			if(isDefined(game["only_welcomemsg"]))
				self duffman\_common::iPrintBig("ONLY_WELCOME","MODE",game["only_welcomemsg"]);
		}
		wait .05;
		if(getDvarInt("g_gravity") == 40)
			setDvar("g_gravity",800);		
		level.allowpickup = true;
		if(!isDefined(game["only_weapon"]) || game["only_weapon"] == "*")
			continue;
		self thread InfinityWeaponAmmo(game["only_weapons"]);	
		level.allowpickup = false;	
		weapon = strTok(game["only_weapon"],";");
		self TakeAllWeapons();
		if(weapon[0] == "knife_mp") {
			self giveWeapon( "deserteaglegold_mp" );
			self setWeaponAmmoStock( "deserteaglegold_mp", 0 );
			self setWeaponAmmoClip( "deserteaglegold_mp", 0 );
			wait .05;
			self switchToWeapon( "deserteaglegold_mp" );
		}
		else if(weapon[0] == "c4_mp") {
			self giveWeapon( "deserteaglegold_mp" );
			self setWeaponAmmoStock( "deserteaglegold_mp", 0 );
			self setWeaponAmmoClip( "deserteaglegold_mp", 0 );
			wait .05;
			self switchToWeapon( "deserteaglegold_mp" );
			self giveWeapon("c4_mp");
			self GiveMaxAmmo( "c4_mp" );
			self SetActionSlot( 3, "weapon","c4_mp");
		}		
		else {
			if(weapon[0] == "schwebepumpe") {
				weapon = strTok("m1014_mp;winchester1200_mp",";");
				setDvar("g_gravity",40);
			}
			for(i=0;i<weapon.size;i++) {
				self giveWeapon( weapon[i] );
				self GiveMaxAmmo( weapon[i] );			
			}
			wait .05;
			self switchToWeapon( weapon[randomint(weapon.size)] );				
		}
	}
}

InfinityWeaponAmmo(weapon) {
	self endon("disconnect");
	self endon("spawned");
	self endon("new_only_weapon");
	weapon = strTok(weapon,";");
	while(1) {
		for(i=0;i<weapon.size;i++) {
			self GiveMaxAmmo( weapon[i] );
		}
		wait 1;
	}
}

CustomEmblem() {
	self endon("disconnect");
	self freezeControls(1);
	y = 90;
	offset = 16.8;
	red = self duffman\_common::addTweakbar(-95,y,255/2,0,255,255/15);
	green = self duffman\_common::addTweakbar(-95,y + offset,255/2,0,255,255/15);
	blue = self duffman\_common::addTweakbar(-95,y + offset + offset,255/2,0,255,255/15);
	alpha = self duffman\_common::addTweakbar(-95,y + offset + offset + offset,.5,0,1,.05);
	modes = duffman\_common::array(red,green,blue,alpha);
	current = modes.size-1;
	weap = "ak74u_mp";
	from = self;
	shader = [];
	for(i=0;i<9;i++) {
		shader[i] = duffman\_killcard::hud( self, 0, 150, 1, "center", "top", 1.4 );
		shader[i].horzAlign = "center";
		shader[i].vertAlign = "middle";
		shader[i].sort = 100+i;
	}
	design = duffman\_common::array((0.3,0.3,0.3),0.6,"white",252,72,"middle",185);
	shader[0] SetShader(design[2],design[3],design[4]);
	shader[0].color = design[0];
	shader[0].y = design[6];
	shader[0].alignY = design[5];
	shader[0].alpha = design[1];
	design = duffman\_common::array((1,1,1),0.8,"nightvision_overlay_goggles",250,70,"middle",185);
	shader[1] SetShader(design[2],design[3],design[4]);
	shader[1].color = design[0];
	shader[1].alpha = design[1];
	shader[1].y = design[6];
	shader[1].alignY = design[5];	
	design = duffman\_common::array((1,1,1),0.1,"white",250,30,"middle",165);
	shader[2] SetShader(design[2],design[3],design[4]);
	shader[2].alpha = design[1];
	shader[2].color = design[0];
	shader[2].y = design[6];
	shader[2].alignY = design[5];
	rankicon = maps\mp\gametypes\_rank::getRankInfoIcon( from.pers["rank"], 0 );
	rank = from.pers["rank"];
	if(from.pers["rank"] == 54 && from getStat(634) != 0) {
		rankicon = from duffman\_prestige::getPrestigeIcon();
		rank = int(from getStat(635)/255*54);
	}
	shader[3] SetShader(rankicon,35,35);
	shader[3].x = -98;
	shader[3].y = 168;	
	if(from duffman\_common::hasPermission("3xP-Member"))
		shader[4].label = &"^53xP^7' Member\n            Lv: &&1";
	else
		shader[4].label = &"Lv: &&1";
	shader[4] setValue(rank+1);
	shader[4].x = -75;
	shader[4].y = 152;	
	alternatewep = "o_O";
	shader[5] duffman\_killcard::setWeaponIcon(weap,alternatewep);
	shader[5].x = 80;
	shader[5].y = 185;	
	shader[5].alignX = "center";
	shader[5].alignY = "middle";
	shader[6] setText(from.pers["emblem"]);
	shader[6].y = 200;
	shader[6].glowColor = (.4,.4,.4);
	shader[6].glowAlpha = 1;
	shader[7] setValue(self duffman\_killcard::getKillStat(from GetEntityNumber()));
	shader[7].x = -7;
	shader[7].y = 175;	
	shader[7].alignX = "right";
	shader[7].font = "objective";
	shader[7].fontscale = 2;	
	shader[7].glowColor = (.4,.4,.4);
	shader[7].glowAlpha = 1;
	shader[8].label = &"-&&1";
	shader[8] setValue(from duffman\_killcard::getKillStat(self GetEntityNumber()));
	shader[8].x = -6.6;
	shader[8].y = 175;	
	shader[8].alignX = "left";
	shader[8].font = "objective";
	shader[8].fontscale = 2;
	shader[8].glowColor = (.4,.4,.4);
	shader[8].glowAlpha = 1;
	for(i=0;i<shader.size;i++) {
		old = shader[i].y;
		shader[i].y = 300;
		shader[i] MoveOverTime(.3);
		shader[i].y = old;
	}
	//-----------------------
	intro = duffman\_common::addTextHud( self, 100,100, 1, "center", "middle", "center", "middle", 1.6, 99 );
	intro setText("Press ^3[Melee^7/^3Use] ^7to change Values\nPress^3 [Frag]^7 to switch between colormodes\nPress ^3[Attack]^7 to save");
	colors = duffman\_common::addTextHud( self, -160,90, 1, "center", "middle", "center", "middle", 1.4, 99 );
	colors setText("^1Red:\n^2Green:\n^4Blue:\n^7Alpha:");
	while(!self AttackButtonPressed()) {
		shader[0].color = (self.tweakvalue[red].selection/255,self.tweakvalue[green].selection/255,self.tweakvalue[blue].selection/255);
		shader[0].alpha = self.tweakvalue[alpha].selection;
		shader[1].color = (self.tweakvalue[red].selection/255,self.tweakvalue[green].selection/255,self.tweakvalue[blue].selection/255);
		shader[1].alpha = self.tweakvalue[alpha].selection;
		shader[2].color = (self.tweakvalue[red].selection/255,self.tweakvalue[green].selection/255,self.tweakvalue[blue].selection/255);
		shader[2].alpha = self.tweakvalue[alpha].selection/2;
		wait .05;
		if(self FragButtonPressed()) {
			current++;
			if(current >= modes.size)
				current = 0;
			for(i=0;i<self.tweakvalue.size;i++) {
				if(isDefined(self.tweakvalue[i]))
					self.tweakvalue[i].foreground = 0;
			}
			self.tweakvalue[current].foreground = 1;
			while(self FragButtonPressed()) wait .05;
		}
	}
	
	col = (self.tweakvalue[red].selection/255,self.tweakvalue[green].selection/255,self.tweakvalue[blue].selection/255);
	alp = self.tweakvalue[alpha].selection;
	string = "addDesign(\"XXXX\",0,"+col+","+alp+",\"white\",252,72,\"middle\",185);\naddDesign(\"XXXX\",1,"+col+","+alp+",\"nightvision_overlay_goggles\",250,70,\"middle\",185);\naddDesign(\"XXXX\",2,"+col+","+alp/2+",\"white\",250,30,\"middle\",165);";
	filename = ""+randomint(999) +""+ randomint(999)+".theme";
	intro.x = 0;
	intro.y = 0;
	intro setText("Please make a screenshot and send it to DuffMan via Xfire (mani96x)\nPlease note only good themes will be added to the public server\nAdditional info:\n ^5 ^6 ^7 Filename: " + filename + "\n ^5 ^6 ^7 Created by: " + self.name + "\n ^5 ^6 ^7 Guid: " + getSubStr(self getGuid(),24,32));
	colors.x = 100;
	colors.y = 100;
	colors setText("Press ^3[USE] ^7to close without saving\nPress ^3[MELEE] ^7to close and save file");
	while(self useButtonPressed() || self meleebuttonpressed()) wait .05;
	while(!self useButtonPressed() && !self meleebuttonpressed()) wait .05;
	if(self meleebuttonpressed())
		duffman\_common::log("themes/"+filename,string,"write");
	for(i=0;i<shader.size;i++) {
		shader[i] MoveOverTime(.3);
		shader[i].y = 300;
	}
	wait .5;
	for(i=0;i<shader.size;i++) 
		if(isDefined(shader[i])) 
			shader[i] Destroy();
	intro destroy();
	colors destroy();
	self freezeControls(0);
}
GiveFreeKill() {
	self.cur_kill_streak++;
	self thread maps\mp\gametypes\_hardpoints::giveHardpointItemForStreak();
	self iPrintLn("Killstreak: " + self.cur_kill_streak);
}
addBot(team) {
	if(isDefined(team) && team == "myteam")
		bot = duffman\_common::addBotClient(self.pers["team"]);
	else 
		bot = duffman\_common::addBotClient(level.otherteam[self.pers["team"]]);
	bot setOrigin(self.origin);
}
addFrozenBot(team) {
	if(isDefined(team) && team == "myteam")
		bot = duffman\_common::addBotClient(self.pers["team"]);
	else 
		bot = duffman\_common::addBotClient(level.otherteam[self.pers["team"]]);
	bot setOrigin(self.origin);
	bot SetPlayerAngles(self GetPlayerAngles());
	bot FreezeControls(1);
	bot duffman\_common::setHealth(99999999);
}
removeBots() {
	removeAllTestClients();
}
ClassEditor() {
	self openMenu(game["menu_eog_main"]);
}
PromodTweaks() {
	self iprintln("^1Setting ^2Promod ^1Dvars");
 	self setClientDvars( "aim_automelee_enabled",0, 
        "aim_automelee_range", 0,
        "dynent_active", 0,
        "snaps", 30,
        "cg_nopredict", 0,
        "cg_crosshairenemycolor", 0,
        "sm_enable", 0,
        "r_dlightlimit", 0,
        "r_lodscalerigid", 1,
        "r_lodscaleskinned", 1,
        "cg_drawcrosshairnames", 0,
        "cg_descriptivetext", 0,
        "cg_viewzsmoothingmin", 1,
        "cg_viewzsmoothingmax", 16,
        "cg_viewzsmoothingtime", 0.1,
        "cg_huddamageiconheight", 64,
        "cg_huddamageiconwidth", 128,
        "cg_huddamageiconinscope", 0,
        "cg_huddamageiconoffset", 128,
        "cg_huddamageicontime", 2000,
        "ragdoll_enable", 0,
        "r_filmtweakinvert", 0,
        "r_desaturation", 0,
        "r_dlightlimit", 0,
        "r_fog", 0,
        "r_specularcolorscale", 0,
        "r_zfeather", 0,
        "fx_drawclouds", 0,
        "rate", 25000,
        "cl_maxpackets", 100,
        "developer", 0,
        "phys_gravity", -800,
   		"r_filmusetweaks", 1,
   		"cg_fovScale", 1.125
   	);
}
changelog() {
	self endon("disconnect");
	shader = [];
	for(i=0;i<2+game["version"].size;i++) {
		shader[i] = duffman\_common::addTextHud( self, 0, 0, .6, "center", "middle", "center","middle",1.6, 9999 + i );	
	  	shader[i] thread FadeIn(.5);
	}
	shader[0] SetShader("white",402,(game["version"].size*20)+22 );
	shader[1] SetShader("black",400,(game["version"].size*20)+20);
	shader[2].alignX = "center";
	shader[2].alignY = "bottom";
	shader[2].y = -10*(game["version"].size-1)+(20*(game["version"].size)) - 9;
	shader[2] setText(self duffman\_common::getLangString("HELP_CLOSE"));	
	for(i=3;i<2+game["version"].size;i++) {
		shader[i].alpha = 1;
		shader[i].y = -10*(game["version"].size-1)+(20*(i-3));
		shader[i].alignX = "left";
		shader[i].x = -185;
		shader[i] setText(game["version"][i-2]);	
	}
	while(self MeleeButtonPressed()) wait .05;
	while(!self MeleeButtonPressed()) wait .05;
	for(i=0;i<shader.size;i++)
		shader[i] thread FadeOut(.5);		
}