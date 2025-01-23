/**
* Name: FinalProj
* Based on the internal empty template. 
* Author: bogdan
* Tags: 
*/


model FinalProj

/* Insert your model definition here */
global {
	int numberOfPeople<-50;
	int numberOfExtro<-11;
	int numberOfIntro<-11;
	int numberOfRebel<-11;
	int numberOfPlayboy<-11;
	int numberOfTeacher<-6;
	
	float globalIntro<-50.0;
	float globalExtro<-50.0;
	float globalPlayboy<-50.0;
	float globalRebel<-50.0;
	float globalTeacher<-50.0;
	float globalHappiness <- 50.0;
	int numberOfCalls<-0;
	Lib TheLibrary <- nil;
	Club TheClub <- nil;
	
	init {
		create Person number:numberOfPeople;
		create Lib;
		create Club;
		
		TheLibrary <- Lib[0];
		TheClub <- Club[0];
		
 		loop i from:1 to:numberOfExtro{
			Person guest <- Person[i-1];
			guest <- guest.setUp("extro",i);
		}
		
		loop i from:1 to:numberOfIntro{
			Person guest <- Person[i+numberOfExtro-1];
			guest <- guest.setUp("intro",i);
		}
		
		loop i from:1 to:numberOfRebel{
			Person guest <- Person[i+numberOfExtro+numberOfIntro-1];
			guest <- guest.setUp("rebel",i);
		}
		
		loop i from:1 to:numberOfPlayboy{
			Person guest <- Person[i+numberOfExtro+numberOfIntro+numberOfRebel-1];
			guest <- guest.setUp("playboy",i);
		}
		
		loop i from:1 to:numberOfTeacher{
			Person guest <- Person[i+numberOfExtro+numberOfIntro+numberOfRebel+numberOfPlayboy-1];
			guest <- guest.setUp("teacher",i);
		}
		
		
	}
	reflex computeHappiness{
		float localHappiness<-0.0;
		loop i from: 1 to: numberOfPeople{
			localHappiness<-localHappiness+Person[i-1].happy;
		}
		globalHappiness<-localHappiness/numberOfPeople;
		
		write "GLOBAL HAPPINESS: " + globalHappiness;
	}
	
	reflex computeHappinessLocal{
		int localHappinessIntro<-nil;
		int localHappinessExtro<-nil;
		int localHappinessRebel<-nil;
		int localHappinessPlayboy<-nil;
		int localHappinessTeacher<-nil;
		
		
		loop i from: 1 to: numberOfPeople{
			if (Person[i-1].type="intro"){
				localHappinessIntro<-localHappinessIntro+Person[i-1].happy;
			}
			if (Person[i-1].type="extro"){
				localHappinessExtro<-localHappinessExtro+Person[i-1].happy;
			}
			if (Person[i-1].type="rebel"){
				localHappinessRebel<-localHappinessRebel+Person[i-1].happy;
			}
			if (Person[i-1].type="playboy"){
				localHappinessPlayboy<-localHappinessPlayboy+Person[i-1].happy;
			}
			if (Person[i-1].type="teacher"){
				localHappinessTeacher<-localHappinessTeacher+Person[i-1].happy;
			}
			
		}
		globalIntro<-localHappinessIntro/numberOfExtro;
		globalExtro<-localHappinessExtro/numberOfIntro;
		globalRebel<-localHappinessRebel/numberOfRebel;
		globalPlayboy<-localHappinessPlayboy/numberOfPlayboy;
		globalTeacher<-localHappinessTeacher/numberOfTeacher;
		
		
		
		write("Intro happiness: " + globalIntro);
		write("Extro happiness: " + globalExtro);
		write("Rebel happiness: " + globalRebel);
		write("Playboy happiness: " + globalPlayboy);
		write("Teacher happiness: " + globalTeacher);
		write("Number of calls: " + numberOfCalls);
		
		
	}
}

species Club{
	string name<-nil;
	int size<-10;
	
	list<Person> peoplePresent <- [];
	

	
	aspect base{
		draw square(size) color: rgb("black") wireframe: true;
		draw square(3) color: rgb("yellow");
	}
	
	reflex check_density{
		ask Person{
			if (!(myself.peoplePresent contains self)){
				if self.hasTargetClub and self.readyToInteract{
					if self.location distance_to myself.location < myself.size{
						myself.peoplePresent[0] +<- self;
					}
				
				
				}
			}
		}
		//write(peoplePresent);
	}
	
	//interaction is the same as in the library, except for:
	//Playboys will offer services, so not normal interaction
	//Playboys can get shy if the awkward flip is true when they meet a teacher, so they get -happy. Teacher will get -happy as well
	//Introverts will get -happy if they meet with a teacher (theyll be ashamed)
	reflex interaction{
		
		loop while: (length(peoplePresent)>1){
			Person p1 <- one_of(peoplePresent);
			int tries_to_get_playboy<-0;
			loop while: (tries_to_get_playboy<3 and p1.type!="playboy" ){
				p1 <- one_of(peoplePresent);
				tries_to_get_playboy<-tries_to_get_playboy+1;	
			}
			peoplePresent >- p1;
			Person p2 <- one_of(peoplePresent);
			peoplePresent >- p2;
			
			if (p1.type>p2.type){
				Person p3 <- nil;
				p3<-p1;
				p1<-p2;
				p2<-p3;
			}
			
			if (p1.type="extro"){
				if (p2.type="intro"){
					//SCENARIO if extro offers something and intro refuses, they have a bad interaction
					
					float genChance<-p1.generous/100;
					float avoidChance<-p2.avoid/100;
					
					bool chance_to_offer<-flip(genChance);
					bool chance_to_avoid<-flip(avoidChance);
					
					
					if (chance_to_offer and chance_to_avoid){
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
						
						//write (p1.name + " and " + p2.name + " had a bad interaction");
						
						ask p1{
							self.hasTargetLibrary<-false;
						}
						ask p2{
							self.hasTargetLibrary<-false;
						}
						
					}
					else{
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " and " + p2.name + " had a good interaction");
					}
					
				}
				else if (p2.type="extro"){
					//SCENARIO 2 types that are the same will always have a good interaction
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+2;
						
						ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " and " + p2.name + " had a good interaction");
										
				}
				else if (p2.type="rebel"){
					//SCENARIO a rebel will decrease the happiness of the extrovert with a value of mayhem/100, and increase his happiness by a constant 5
						p1.happy<-p1.happy-p2.mayhem/100;
						p2.happy<-p2.happy+2;
						
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got traumatised by " + p2.name);
				}
				else if (p2.type="playboy"){
					//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +6 happiness with an extro.
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+4;
						
						ask p1{
							self.readyToInteract<-false;
							self.lonely<-0;
							write("interacted///////////////////////////////////////////////////////////////////////////////");
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got good with " + p2.name);
					
				}
				else if (p2.type="teacher"){
					//SCENARIO extro only like friendly teachers
					
					bool chance_smart <- flip(p2.friendly/100);
					
					if (chance_smart){
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+2;
					}
					else{
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
					}
					
					ask p1{
							self.readyToInteract<-false;
						}
					ask p2{
							self.readyToInteract<-false;
						}
					
				}
			}
			else if (p1.type="intro"){
				if (p2.type="intro"){
					//SCENARIO 2 types that are the same will always have a good interaction
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+2;
						
						ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						//write (p1.name + " and " + p2.name + " had a good interaction");
				}
				else if (p2.type="rebel"){
					//SCENARIO a rebel will decrease the happiness of the introvert with a value of mayhem/50, and increase his happiness by a constant 7
						p1.happy<-p1.happy-p2.mayhem/50;
						p2.happy<-p2.happy+2;
						
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got traumatised by " + p2.name);
				}
				else if (p2.type="playboy"){
					//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +3 happiness with an intro.
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+1;
						
						ask p1{
							self.readyToInteract<-false;
							self.lonely<-0;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got good with " + p2.name);
					
				}
				else if (p2.type="teacher"){
					//SCENARIO introverts only like skilled teachers
					bool chance_smart <- flip(p2.smart/100);
					
					if (chance_smart){
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+2;
					}
					else{
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
					}
					
					ask p1{
							self.readyToInteract<-false;
						}
					ask p2{
							self.readyToInteract<-false;
						}
					
				}
			}
			else if (p1.type="playboy"){
				if (p2.type="rebel"){
					//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +5 happiness with a rebel.
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+2;
						
						ask p1{
							self.readyToInteract<-false;
							
						}
						ask p2{
							self.lonely<-0;
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got good with " + p2.name);
					
				}
				else if (p2.type="playboy"){
					//////
				}
				else if (p2.type="teacher"){
					//SCENARIO a playboy has a chance to get shy with teachers and ruin it
					bool chance_to_shy <- flip(p1.awkward/100);
					
					if (chance_to_shy){
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
						
					}
					else{
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+2;
					}
					
					ask p1{
							self.readyToInteract<-false;
							
						}
						ask p2{
							self.lonely<-0;
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got good with " + p2.name );
				}
			}
			else if (p1.type="rebel"){
				if (p2.type="rebel"){
					//SCENARIO 2 rebels will always get along
					
						p1.happy<-p1.happy+2;
						p2.happy<-p2.happy+2;
						
						ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						//write (p1.name + " and " + p2.name + " had a good interaction");
				}
				else if (p2.type="teacher"){
					//Scenario rebels never like teachers
					p1.happy<-p1.happy-8;
					p2.happy<-p2.happy+1;
					
					ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						//write (p1.name + " and " + p2.name + " had a bad interaction");
				}
				
			}
			else if (p1.type="teacher"){
				if (p2.type="teacher"){
					//SCENARIO 2 2 teachers will always get along
					
					p1.happy<-p1.happy+2;
					p2.happy<-p2.happy+2;
					
					ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " had a good interaction with " + p2.name);
				}
			}
				
		}
					
		
	
	}
	
}

species Lib{
	string Name<-nil;
	int size<-10;
	int density<-0;
	int temp_ctdn<-20;
	
	list<Person> peoplePresent <- [];
	

	
	aspect base{
		draw square(size) color: rgb("black") wireframe: true;
		draw square(3) color: rgb("pink");
	}

	
	reflex check_density{
		ask Person{
			if (!(myself.peoplePresent contains self)){
				if self.hasTargetLibrary and self.readyToInteract{
					if self.location distance_to myself.location < myself.size{
						myself.peoplePresent[0] +<- self;
					}
				
				
				}
			}
		}
		//write(peoplePresent);
	}
	//extro, intro, playboy, rebel, teacher
	reflex interaction{
		
		loop while: (length(peoplePresent)>1){
			Person p1 <- one_of(peoplePresent);
			peoplePresent >- p1;
			p1.happy<-p1.happy-1;
			Person p2 <- one_of(peoplePresent);
			peoplePresent >- p2;
			p2.happy<-p2.happy-1;
			
			
			if (p1.type>p2.type){
				Person p3 <- nil;
				p3<-p1;
				p1<-p2;
				p2<-p3;
			}
			
			if (p1.type="extro"){
				if (p2.type="intro"){
					//SCENARIO if extro offers something and intro refuses, they have a bad interaction
					
					float genChance<-p1.generous/100;
					float avoidChance<-p2.avoid/100;
					
					bool chance_to_offer<-flip(genChance);
					bool chance_to_avoid<-flip(avoidChance);
					
					
					if (chance_to_offer and chance_to_avoid){
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
						
						//write (p1.name + " and " + p2.name + " had a bad interaction");
						
						ask p1{
							self.hasTargetLibrary<-false;
						}
						ask p2{
							self.hasTargetLibrary<-false;
						}
						
					}
					else{
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " and " + p2.name + " had a good interaction");
					}
					
				}
				else if (p2.type="extro"){
					//SCENARIO 2 types that are the same will always have a good interaction
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
						
						ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " and " + p2.name + " had a good interaction");
										
				}
				else if (p2.type="rebel"){
					//SCENARIO a rebel will decrease the happiness of the extrovert with a value of mayhem/100, and increase his happiness by a constant 5
						p1.happy<-p1.happy-p2.mayhem/100;
						p2.happy<-p2.happy+5;
						
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got traumatised by " + p2.name);
				}
				else if (p2.type="playboy"){
					//SCENARIO extro always has a good time with pboy
					
					
					p1.happy<-p1.happy+5;
					p2.happy<-p2.happy+5;
					
					
					ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
					
					//write (p1.name + " had a good time with " + p2.name);	
				}
				else if (p2.type="teacher"){
					//SCENARIO extro only like friendly teachers
					
					bool chance_smart <- flip(p2.friendly/100);
					
					if (chance_smart){
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
					}
					else{
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
					}
					
					ask p1{
							self.readyToInteract<-false;
						}
					ask p2{
							self.readyToInteract<-false;
						}
					
				}
			}
			else if (p1.type="intro"){
				if (p2.type="intro"){
					//SCENARIO 2 types that are the same will always have a good interaction
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
						
						ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						//write (p1.name + " and " + p2.name + " had a good interaction");
				}
				else if (p2.type="rebel"){
					//SCENARIO a rebel will decrease the happiness of the introvert with a value of mayhem/50, and increase his happiness by a constant 7
						p1.happy<-p1.happy-p2.mayhem/50;
						p2.happy<-p2.happy+7;
						
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got traumatised by " + p2.name);
				}
				else if (p2.type="playboy"){
					//SCENARIO based on how friendly a playboy is, introvert has a good time
					bool chance_for_good_time<-flip(p2.friendly);
					if (chance_for_good_time){
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
					}
					else{
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
					}
					
					ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
				}
				else if (p2.type="teacher"){
					//SCENARIO introverts only like skilled teachers
					
					bool chance_smart <- flip(p2.smart/100);
					
					if (chance_smart){
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
					}
					else{
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
					}
					
					ask p1{
							self.readyToInteract<-false;
						}
					ask p2{
							self.readyToInteract<-false;
						}
					
				}
			}
			else if (p1.type="rebel"){
				if (p2.type="rebel"){
					//SCENARIO 2 rebels will always get along
					
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
						
						ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						//write (p1.name + " and " + p2.name + " had a good interaction");
				}
				else if (p2.type="teacher"){
					//Scenario rebels never like teachers
					p1.happy<-p1.happy-8;
					p2.happy<-p2.happy+3;
					
					ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						//write (p1.name + " and " + p2.name + " had a bad interaction");
				}
			}
			else if (p1.type="playboy"){
				if (p2.type="rebel"){
					//SCENARIO a rebel will decrease the happiness of the playboy with a value of mayhem/50, and increase his happiness by a constant 5
						p1.happy<-p1.happy-p2.mayhem/100;
						p2.happy<-p2.happy+5;
						
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got traumatised by " + p2.name);
						
				}
				else if (p2.type="playboy"){
					//SCENARIO 2 playboys get along
					
					p1.happy<-p1.happy+5;
					p2.happy<-p2.happy+5;
					
					ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " had a good interaction with " + p2.name);
					
					
				}
				else if (p2.type="teacher"){
					//SCENARIO if one of them is friendly, they good
					
					bool chance_friendly1 <- flip(p1.friendly/100);
					bool chance_friendly2 <- flip(p1.friendly/100);
					
					if (chance_friendly1 or chance_friendly2){
						p1.happy<-p1.happy+5;
						p2.happy<-p2.happy+5;
					}
					else{
						p1.happy<-p1.happy-5;
						p2.happy<-p2.happy-5;
					}
					
					ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " had interacted with " + p2.name);
				}
			}
			else if (p1.type="teacher"){
				if (p2.type="teacher"){
					//SCENARIO 2 2 teachers will always get along
					
					p1.happy<-p1.happy+5;
					p2.happy<-p2.happy+5;
					
					ask p1{
							if (!(p1.friends contains p2)){
								p1.friends[0]+<-p2;
							}
							self.readyToInteract<-false;
						}
						ask p2{
							if (!(p2.friends contains p1)){
								p2.friends[0]+<-p1;
							}
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " had a good interaction with " + p2.name);
				}
			}
			
			
				
		}
		
	}
	

}

species Person skills:[moving,fipa] control: simple_bdi{
	
	
	string name <- nil;
	string type <- nil;
	bool busy <- false;
	bool readyToInteract <- true;
	int delayCounter <- 0;
	bool hasTargetLibrary<-false;
	bool hasTargetClub<-false;
	point targetLocation<-nil;
	int distanceThreshhold <- 10;
	
	int timeSpentInLibrary;
	int timeSpentInClub;
	rgb agentColor<-rgb("green");
	
	list<Person> friends<-[];
	
	
	int happy <- 50;
	int study <- nil;
	int avoid <- nil;
	int lonely <- nil;
	int generous <- nil;
	int mayhem <- nil;
	int friendly<-nil;
	int awkward<-nil;
	int smart <- nil;
	
	
	aspect base{
		
		draw circle(1) color: agentColor;
	}
		reflex control_happy_and_lonely_and_study{
		if lonely>=90{
			lonely<-90;
		}
		if happy>=90{
			happy<-90;
		}
		if study>=90{
			study<-90;
		}
		if lonely<=10{
			lonely<-10;
		}
		if happy<=10{
			happy<-10;
		}
		if study<=10{
			study<-10;
		}
	}
	action setUp(string typeLocal,int i){
		name<-typeLocal+i;
		type<-typeLocal;
		
		if (type="intro"){
			study <- rnd(1,100);
			avoid <- rnd(50,100);
			lonely <- rnd(20,40);
			
			agentColor<-rgb("pink");	
		}
		else if (type="extro"){
				study <- rnd(1,100);
				generous <- rnd(50,100);
				lonely <- rnd(20,40);
				agentColor<-rgb("blue");			
		}
		else if (type="rebel"){
			study <- rnd(1,50);
			mayhem <- rnd(20,100);
			lonely <- rnd(20,40);
			agentColor<-rgb("black");
		}
		else if (type="playboy"){
			study <- rnd(1,100);
			awkward <- rnd(1,100);
			friendly <- rnd(1,100);
			agentColor<-rgb("orange");
		}
		else if (type="teacher"){
			smart <- rnd(1,100);
			friendly <- rnd(1,100);
			lonely<-rnd(20,40);
			agentColor<-rgb("green");
		}
		
	}
	
	action callAll{
		loop i from:1 to: 20{
			write(Person[i-1].name);
		}
	}
	
	reflex lonely_Check {
		if (type != "playboy"){
			lonely<-lonely+1;
			if (lonely>90){
				write(name + " too lonely");
				happy<-happy-1;
			}
			
		}
	}
	
	reflex move_Random when:(!hasTargetLibrary and !hasTargetClub){
		//agentColor<-rgb("green");
		
		
		if (type="playboy"){
			hasTargetClub<-flip(0.2);
			if (hasTargetClub){
				targetLocation<-TheClub.location;
				//write(name + " has target: CLUB");
			}
		}
		else if (lonely>80){
			hasTargetClub<-flip(0.5);
			if (hasTargetClub){
				targetLocation<-TheClub.location;
				//write(name+ " has target: CLUB");
			}
		}
		
		if (!hasTargetClub){
			hasTargetLibrary<-flip(0.05);
			if (hasTargetLibrary){
				targetLocation<-TheLibrary.location;
				//write(name+" has target: LIB");
				
			}
			else{
				hasTargetClub<-flip(0.05);
				if (hasTargetClub){
					targetLocation<-TheClub.location;
					//write(name+ " has target: CLUB");
				}
				else{
					if (friends!=[]){
						if (flip(0.1)){
							do start_call;
						}
					}
				}
			}
			do wander speed:10.0;
			
		}
		
	}
	
	action start_call{
		write("Starting call");
		Person target<-one_of(friends);
		do start_conversation to: list(target) protocol:'no-protocol' performative: 'inform' contents: ["How do u do I need to talk",target];
		
	}
	
	reflex receiveInforms when: !empty(informs){
			message msg;
			
			loop informMsg over: informs{
				string dummy <- informMsg.contents;
				string sender <- informMsg.sender;
				write("I received a message, im answering now");
				write("The call is between " + self + " and " + sender);
				write("" + self + " +5 happy");
				self.happy<-self.happy+5;
				do propose message: informMsg contents: ["Im good and u"];						
			}
			
	}
	
	reflex receiveAnswers when: !empty(proposes){
		
		loop msg over:proposes{
			string dummy <-msg.contents[0];
			
			write (dummy);
			write(""+self + " +5 happy");
			self.happy<-self.happy+5;
			write ("ending conv now");
			do end_conversation message:msg contents:['Good, bye!'];
			
			numberOfCalls<-numberOfCalls+1;
					
			
		}
	
	}
		
	
	
	reflex move_to_library when:(hasTargetLibrary) {
		speed <- 5.0;
		if (self.location distance_to targetLocation)>distanceThreshhold{
			do goto target: targetLocation;
			timeSpentInLibrary<-0;
			
		}
		else{
			//agentColor<-rgb("pink");
			timeSpentInLibrary<-timeSpentInLibrary+1;
		}
		
	}
	
	reflex move_to_club when:(hasTargetClub){
		speed <- 5.0;
		if (self.location distance_to targetLocation)>distanceThreshhold{
			do goto target: targetLocation;
			timeSpentInClub<-0;
			
		}
		else{
			//agentColor<-rgb("pink");
			timeSpentInClub<-timeSpentInClub+1;
		}
	}
	
	reflex time_to_leave_lib when:timeSpentInLibrary>6{
		hasTargetLibrary<-false;
	}
	
	reflex time_to_leave_club when: timeSpentInClub>10{
		hasTargetClub<-false;
	}
	
	reflex delay_between_interactions when:readyToInteract=false{
		if (delayCounter<5){
			delayCounter<-delayCounter+1;
		}
		else{
			//write(name + "is ready to interact");
			readyToInteract<-true;
			delayCounter<-0;
		}
	}
		
}




experiment myExperiment type:gui{
	output{
		display myDisplay {
			species Person aspect:base;
			species Lib aspect:base;
			species Club aspect:base;
		}
		
        display chart type: 2d {
			chart "Total Happiness" type: series {
    	    data "Total Happiness" value: globalHappiness color: #blue;
   			}
		}
		display chart2 type: 2d {
			chart "Individual Happiness" type: series {
        	data "Intro Happiness" value: globalIntro color: #pink;
        	data "Extro Happiness" value: globalExtro color: #blue;
        	data "Rebel Happiness" value: globalRebel color: #black;
        	data "Playboy Happiness" value: globalPlayboy color: #orange;
        	data "Teacher Happiness" value: globalTeacher color: #green;
    }
		}
    }
	
}