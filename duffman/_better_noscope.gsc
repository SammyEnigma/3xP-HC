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
	setDvar("player_breath_gasp_lerp",0);
	if(!isDefined(game["roundsplayed"]) || game["roundsplayed"] == 0)
		setDvar("noscope","0");
	addConnectThread(::BetterNoScope);
}

BetterNoScope() {
	self endon("disconnect");
	bodypart[0] = "torso_upper";
	bodypart[1] = "head";
	while(1) {
		kills = self.pers["kills"];
		rand = randomint(2);
		self waittill( "weapon_fired" );
		if(self isScope() && !self playerAds() && getDvar("noscope") != "off") {
			oldori = self.origin;
			wep = self getCurrentWeapon();
			angle = self getPlayerAngles();
			wait .05;
			player = self getBestPlayer(angle); // player[0] = bestplayer
										   // player[1] = angledistance
			if(isDefined(player[0])) {
				luck = betterRandomInt(int(((distance(player[0].origin,self.origin) + 200)/ 300) + player[1] + (distance(self.origin,oldori)!=0) - player[0] SightConeTrace( self getEye(), self ))+1);
				if(kills == self.pers["kills"] && (luck == rand||getDvarInt("noscope")||level.displayMapEndText)) {
					player[0] thread [[level.callbackPlayerDamage]](self,self,120,8,"MOD_RIFLE_BULLET",wep,(0,0,0),(0,0,0),bodypart[(!RandomInt(5))],0);	
				}
			}
		}
	}
}

isScope() {
	return (self GetCurrentWeapon() == "remington700_mp" || self GetCurrentWeapon() == "m40a3_mp");
}

getBestPlayer(angles) {
	best = [];
	angle = 180;
	maxangle = 4;
	if(getDvarint("noscope"))
		maxangle = getDvarint("noscope");	
	players = getEntArray("player","classname");
	for(i=0;i<players.size;i++) {
		if(isDefined(players[i]) && isFalse(players[i].pers["isBot"]) && players[i] != self && (players[i].pers["team"] != self.pers["team"] || !level.teambased)) {
			if(players[i].sessionteam != "spectator" && players[i].health != 0) {
				angledist = getAngleDistance(angles[1],vectorToAngles((players[i].origin)-(self.origin))[1]);
				angledist2 = getAngleDistance(angles[0],vectorToAngles((players[i].origin)-(self.origin))[0]);
				if(angledist < maxangle && angledist < angle && angledist2 < maxangle ) {
					if(players[i] SightConeTrace( self getEye(), self ) != 0 ) {
						angle = angledist;
						best[0] = players[i];
						best[1] = angledist;
					}
				}
			}
		}
	}
	return best;
}