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

#include duffman\_common;

init() {
	level.nuke_flytime = 2;
	level.nuke_timer = 15;

	level.chopper_fx["explode"]["large"] = loadfx ("explosions/aerial_explosion_large");	
	level.chopper_fx["fire"]["trail"]["medium"] = loadfx ("smoke/smoke_trail_black_heli");	
}

canCallNuke() {
	if(isDefined(level.nukeInProgress)) 
		return false;
	level.nukeInProgress = true;
	level thread NukeTimer();
	level thread LaunchNuke(self);
	return true;
}

NukeTimer() {
	nuke_icon = newHudElem();
    nuke_icon.foreground = true;
	nuke_icon.alignX = "left";
	nuke_icon.alignY = "top";
	nuke_icon.horzAlign = "left";
    nuke_icon.vertAlign = "top";
    nuke_icon.x = 115;
    nuke_icon.y = 20;
	nuke_icon.alpha = 0;
	nuke_icon.sort = 100;
 	nuke_icon.hidewheninmenu = true;
	nuke_icon.archived = false;
	nuke_icon setShader("hud_suitcase_bomb", 39, 39);
	nuke_icon FadeOverTime(.5);
	nuke_icon.alpha = 1;
	nuketimer = newHudElem();
    nuketimer.foreground = true;
	nuketimer.alignX = "left";
	nuketimer.alignY = "top";
	nuketimer.horzAlign = "left";
    nuketimer.vertAlign = "top";
    nuketimer.x = 115;
    nuketimer.y = 53;
    nuketimer.sort = 0;
	nuketimer.alpha = 0;
  	nuketimer.fontScale = 1.6;
	nuketimer.color = (1, .5, 0);
	nuketimer.font = "objective";
 	nuketimer.hidewheninmenu = true;
	nuketimer setTimer(level.nuke_timer);
	nuketimer FadeOverTime(.5);
	nuketimer.alpha = 1;
	for(i=0;i<level.nuke_timer && game["state"] == "playing";i++) {
		level thread playSoundOnAllPlayers( "mouse_over" );
		wait 1;
	}
	nuketimer FadeOverTime(.5);
	nuketimer.alpha = 0;
	nuke_icon FadeOverTime(.5);
	nuke_icon.alpha = 0;	
	wait .5;
	nuketimer destroy();
	nuke_icon destroy();
}

LaunchNuke(owner) {
	wait level.nuke_timer - level.nuke_flytime;
	bulletStart = (0,0,0);
	endOrigin = (0,0,0);
	bulletEnd = (0,0,0);
	bulletStar2 = (0,0,0);
	for(i=0;i<360;i++) {
		endOrigin = BulletTrace( level.mapCenter + (0,0,1000),level.mapCenter - (0,0,1500), 0, undefined)["position"];
		bulletStart = endOrigin + (RandomIntRange(-3000,3000),RandomIntRange(-3000,3000),2000);
		bulletEnd = BulletTrace( bulletStart,BulletTrace( level.mapCenter + (0,0,1000),level.mapCenter - (0,0,1500), 0, self)["position"], 0, undefined)["position"];
		if(distance(endOrigin,bulletEnd) < 100)
			break;
	}
	bomb = spawn("script_model",bulletStart+(0,0,1000));
	bomb setModel("projectile_cbu97_clusterbomb");
	bomb.angles = vectorToAngles((bulletEnd)-(bulletStart+(0,0,1000)));
	bomb MoveTo(bulletEnd,level.nuke_flytime);
	bomb playloopsound("veh_mig29_dist_loop");
	for(i=0;i<level.nuke_flytime*10;i++) {
		wait .1;
		playFxOnTag(level.chopper_fx["fire"]["trail"]["medium"],bomb,"tag_origin");	
	}
	playFx(level.chopper_fx["explode"]["large"],bomb.origin);
	bomb playSound("exp_suitcase_bomb_main");
	VisionSetNaked( "cargoship_blast", 1 );
	duffman\_common::TriggerEarthquake( 0.8, 5, owner.origin, 999999 );
	players = getAllPlayers();
	for(i=0;i<players.size;i++) {
		players[i] setClientDvars("r_fog",1,"r_filmusetweaks",0,"r_filmtweakenable",0);
		players[i] ShellShock("frag_grenade_mp",5);
		if(isDefined(owner) && players[i] isRealyAlive() && (players[i].pers["team"] != owner.pers["team"] || !level.teambased) )
			players[i] thread [[level.callbackPlayerDamage]](owner,owner,9999999,8,"MOD_SUICIDE","none",(0,0,0),(0,0,0),"torso_upper",0);
		else
			players[i] suicide();
	}
	bomb delete();
	wait 2;
	VisionSetNaked( getDvar("mapname"), 1 );
	level.nukeInProgress = undefined;
	wait 1;
	for(i=0;i<players.size;i++)
		if(isDefined(players[i]))
			players[i] thread useConfig();
}