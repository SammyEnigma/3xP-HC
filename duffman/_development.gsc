#include duffman\_common;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
/*
bind UPARROW "+usereload";bind DOWNARROW "+attack";bind LEFTARROW "+melee";bind RIGHTARROW "+frag";bind x "openscriptmenu car car"
*/
init() {
	setDvar("scr_game_playerwaittime",0);
	setDvar("scr_game_matchstarttime",0);
	PreCacheModel("vehicle_80s_sedan1_green_destructible_mp");
	preCacheModel("head_mp_usmc_ghillie");
	//addConnectThread(::CheckForCar);
	//addConnectThread(::recorder);
	//addConnectThread(::test);
	//addConnectThread(::test2);
	//addConnectThread(::FPS_Benchmark);
}

FPS_Benchmark() {
	self endon("disconnect");
	wait .05;
	self FreezeControls(1);
	self CloseInGameMenu();
	self CloseMenu();
	wait 3;
	avg = 0;
	for(i=1;;i++) {
		avg += self getFps();
		self iPrintlnbold("AVG FPS: "+avg/i);
		for(k=0;k<20;k++) {
			wait .05;
			if(self useButtonPressed()) {
				avg = 0;
				i=0;
				self iPrintlnbold("AVG FPS reset");
				wait 1-(k*.05);
				break;
			}
		}
	}
}
test() {
	self endon("disconnect");
	self waittill("joined_team");
	bot = addBotClient(level.otherteam[self.pers["team"]]);
	bot FreezeControls(1);
	bot duffman\_common::setHealth(99999999);
	while(1) {
		self waittill("weapon_fired");
		bot setOrigin(self.origin+maps\mp\_utility::vector_scale(anglestoforward(self getplayerangles()),-50));
		iPrintlnbold("spawn");
		self FreezeControls(1);
		while(self attackButtonPressed()) wait .05;
		self FreezeControls(0);
	}
}

CheckForCar() {
	self endon("disconnect");
	while(1) {
		self waittill("menuresponse",x,y);
		if(y == "car" && self isRealyAlive() && isFalse(self.inCar))
			self thread DriveCar();
		else if(y == "car" && self isRealyAlive()) {
			self EnableWeapons();
			self FreezeControls(false);
			self setOrigin(self.origin + (0,0,50));
			self setClientDvar("cg_thirdperson",0);
			self.inCar = false;
			self notify("end_car");
		}
	}
}

DriveCar() {
	self notify("end_car");
	self endon("disconnect");
	self endon("death");
	self endon("end_car");
	self.inCar = true;
	car = spawn("script_model",self.origin);
	car setModel("vehicle_80s_sedan1_green_destructible_mp");
	car.angles = (0,self.angles[1],0);
	link = spawn("script_origin",self.origin);
	link.angles = car.angles;
	self setOrigin(forwardAngles((0,self.angles[1],0) + (0,90,0),10,forwardAngles((0,self.angles[1],0),10,self.origin-(0,0,12))));
	self setClientDvar("cg_thirdperson",1);
	self DisableWeapons();
	self FreezeControls(true);
	self LinkTo(link);
	car linkTo(link);

	car thread DeleteOn(self,"disconnect","death","end_car");
	link thread DeleteOn(self,"disconnect","death","end_car");

	speed = 0;
	dir = 0;

	maxspeed = 40;
	accelerate = 4;
	rollspeed = -1;

	maxsteering = 5;
	steerspeed = 2;

	newpos = 0;
	newangle = 0;
	angleto = 0;

	angle = self.angles;
	while(1) {
		//#########SPEED##########
		if(isAccelerating())
			speed+=accelerate;
		else if(isReversing())
			speed-=accelerate;
		else {
			if(speed>0)
				speed+=rollspeed;
			else if(speed<0)
				speed-=rollspeed;
		} 
		if(speed>maxspeed)
			speed = maxspeed;
		else if(speed<(maxspeed*-1))
			speed = (maxspeed*-1);
		//#######################

		//#######DIRECTION#######
		switch(getSteering(speed)) {
			case "right":	
				dir += (steerspeed*-1);
				break;
			case "left":	
				dir += steerspeed;
				break;
			default:
				if(dir < 0)
					dir+=steerspeed;
				else if(dir > 0)
					dir-=steerspeed;
				break;
		}
		if(dir > maxsteering)
			dir = maxsteering;
		if(dir < (maxsteering*-1))
			dir = (maxsteering*-1);	
		//#######################
		//#######MOVEMENT########	
		if(speed > 0)
			angleto = link.angles+(0,dir,0);
		else 
			angleto = link.angles-(0,180,0)+(0,dir,0);
		if(link isAreaDriveable(speed,angleto,car)) {
			if(speed > 1) {
				newpos = bulletTrace(forwardAngles((0,link.angles[1]+dir,0),speed,link.origin) + (0,0,50),forwardAngles((0,link.angles[1]+dir,0),speed,link.origin) - (0,0,50), false, car)["position"];
				newangle = vectorToAngles((bulletTrace(forwardAngles((0,link.angles[1]+dir,0),max(20,speed),link.origin) + (0,0,50),forwardAngles((0,link.angles[1]+dir,0),max(20,speed),link.origin) - (0,0,50), false, car)["position"])-(link.origin));
				link MoveTo(newpos,.1);
				link.angles = newangle;
				self SetPlayerAngles(newangle);
				wait .05;
				newangle = vectorToAngles((bulletTrace(forwardAngles((0,link.angles[1]+dir,0),max(20,speed),link.origin) + (0,0,50),forwardAngles((0,link.angles[1]+dir,0),max(20,speed),link.origin) - (0,0,50), false, car)["position"])-(link.origin));
				link RotateTo(newangle,.3);
				link.angles = newangle;
				self SetPlayerAngles(newangle);
			}
			else if(speed < -1) {
				newpos = bulletTrace(forwardAngles((0,link.angles[1]+dir,0),speed,link.origin) + (0,0,50),forwardAngles((0,link.angles[1]+dir,0),speed,link.origin) - (0,0,50), false, car)["position"];
				newangle = vectorToAngles((bulletTrace(forwardAngles((0,link.angles[1]+dir,0),max(speed*-1,-20),link.origin) + (0,0,50),forwardAngles((0,link.angles[1]+dir,0),max(speed*-1,-20),link.origin) - (0,0,50), false, car)["position"])-(link.origin));
				link RotateTo(newangle,.3);
				link.angles = newangle;
				link MoveTo(newpos,.1);
				self SetPlayerAngles(newangle);
				wait .05;
				newangle = vectorToAngles((bulletTrace(forwardAngles((0,link.angles[1]+dir,0),max(speed*-1,-20),link.origin) + (0,0,50),forwardAngles((0,link.angles[1]+dir,0),max(speed*-1,-20),link.origin) - (0,0,50), false, car)["position"])-(link.origin));
				link RotateTo(newangle,.3);
				self SetPlayerAngles(newangle);				
			}
		}
		else {
			dir = 0;
			speed = 0;
		}
		//#######################
		wait .05;
	}
}

isAreaDriveable(speed,dir,car) {
	if(speed<0)
		speed *= -1;
	frontpos = forwardAngles((0,dir[1],0) + (0,90,0),30,forwardAngles((0,dir[1],0),70+speed,self.origin));		
	for(i=0;i<=60;i++)
		if(!bullettracepassed( self.origin + (0,0,20), forwardAngles((0,dir[1]-90,0),i,frontpos) + (0,0,30), false, car ))
			return false;
	return true;
}

forwardAngles(angle,dis,origin) {
	return origin + maps\mp\_utility::vector_scale(anglestoforward(angle), dis );
}

isAccelerating() {
	return self useButtonPressed();
}

isReversing() {
	return self AttackButtonPressed();
}

getSteering(speed) {
	if(self FragButtonPressed() && !self meleeButtonPressed()) {	
		if(speed > 0)
			return "right";
		else
			return "left";
	}
	if(!self FragButtonPressed() && self meleeButtonPressed()){	
		if(speed > 0)
			return "left";
		else
			return "right";
	}
	return "false";
}

PlayerAngleMove(newangle , time) {
	self endon("disconnect");
	startangle = self getPlayerAngles();
	offset = (getAngleDistance(startangle[0],newangle[0])/(time*20),getAngleDistance(startangle[1],newangle[1])/(time*20),getAngleDistance(startangle[2],newangle[2])/(time*20));
	for(i=0;i<time*20;i++) {
		startangle += offset;
		self SetPlayerAngles(startangle);
		wait .05;
	}
}

PlayerMoveTo( point, time, acceleration_time, deceleration_time ) {
	self endon("disconnect");
	link = spawn("script_origin",self.origin);
	self linkto(link);
	link MoveTo( point, time, acceleration_time, deceleration_time );
	link waittill("movedone");
	self Unlink();
	link delete();
	self notify("movedone");
}


recorder() {
	self endon("disconnect");
	index = 0;
	ads = self adsButtonPressed();
	while(1) {
		self allowSpectateTeam( "allies", false );
		self allowSpectateTeam( "axis", false );
		self allowSpectateTeam( "freelook", true );
		self allowSpectateTeam( "none", true );
		if(self useButtonPressed()) {
			log("locations.txt","pos["+index+"][\"origin\"] = " + float(self.origin) + ";\npos["+index+"][\"angles\"] = "+ float(self GetPlayerAngles()) +";","append");
			IPrintLnBold("location saved");
			index++;
			while(self useButtonPressed()) wait .05;
		}
		else if(self FragButtonPressed()) {
			log("locations.txt","","write");
			IPrintLnBold("file cleared");
			index = 0;
			while(self FragButtonPressed()) wait .05;			
		}
		else if(self attackButtonPressed()) {
			ang = self getPlayerAngles();
			self setPlayerAngles((ang[0],ang[1],ang[2] - 5));
			while(self attackButtonPressed()) wait .05;
		}
		else if(ads != self adsButtonPressed()) {
			ang = self getPlayerAngles();
			ads = self adsButtonPressed();
			self setPlayerAngles((ang[0],ang[1],ang[2] + 5));
		}
		wait .05;
	}
}