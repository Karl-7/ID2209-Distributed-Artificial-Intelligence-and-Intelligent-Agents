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
	int numberOfExtro<-10;
	int numberOfIntro<-10;
	int numberOfRebel<-10;
	int numberOfPlayboy<-10;
	int numberOfTeacher<-10;
	
	int numberOfClubs<-2;
	
	float globalIntro<-50.0;
	float globalExtro<-50.0;
	float globalPlayboy<-50.0;
	float globalRebel<-50.0;
	float globalTeacher<-50.0;
	float globalHappiness <- 50.0;
	
	float globalIntro_study<-50.0;
	float globalExtro_study<-50.0;
	float globalPlayboy_study<-50.0;
	float globalRebel_study<-50.0;
//	float globalTeacher_study<-50.0;
	float globalHappiness_study <- 50.0;
	
	int numberOfCalls<-0;
	Lib TheLibrary <- nil;
	list<Club> TheClub <- list_with(numberOfClubs,nil);
	Office TheOffice<-nil;
//	Office TheOffice<-nil;
//	string person_is_nice<-"person_is_nice";
	string plby_at_location <- "plby_at_location";
//	string clubs_nearby<-"clubs_nearby";
	predicate plby_near <-new_predicate("plby_near");
	predicate am_happy <-new_predicate("am happy");
	predicate not_happy <-new_predicate("not happy");
	predicate too_lonely <-new_predicate("too_lonely");
	predicate STUDY_WELL <- new_predicate("STUDY_WELL") ;
    predicate BE_HAPPY <- new_predicate("BE_HAPPY") ;
    predicate FIND_PLBY <- new_predicate("FIND_PLBY") ;
 
//    predicate FIND_FRIEND <- new_predicate("FIND_FRIEND") ;
//    predicate SHARE_WITH_FRIEND <- new_predicate("share information") ;
	
	
	init {
		create Person number:numberOfPeople;
		create Lib;
		create Club number:numberOfClubs;
		create Office;
		
		
		loop i from:1 to:numberOfClubs{
			
			Club a_club<-Club[i-1];
			TheClub[i-1]<-a_club;		
		}
		TheLibrary <- Lib[0];

		TheOffice<-Office[0];
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
		
//		write "GLOBAL HAPPINESS: " + globalHappiness;
	}
	
	reflex computeHappinessLocal{
		int localHappinessIntro<-nil;
		int localHappinessExtro<-nil;
		int localHappinessRebel<-nil;
		int localHappinessPlayboy<-nil;
		int localHappinessTeacher<-nil;
		
		int localLonelinessIntro<-nil;
		int localLonelinessExtro<-nil;
		int localLonelinessRebel<-nil;
		int localLonelinessPlayboy<-nil;
		int localLonelinessTeacher<-nil;
		
		int localGradeIntro<-nil;
		int localGradeExtro<-nil;
		int localGradeRebel<-nil;
		int localGradePlayboy<-nil;
//		int localHappinessTeacher<-nil;
		
		loop i from: 1 to: numberOfPeople{
			if (Person[i-1].type="intro"){
				localHappinessIntro<-localHappinessIntro+Person[i-1].happy;
				localLonelinessIntro<-localLonelinessIntro+Person[i-1].lonely;
				localGradeIntro<-localGradeIntro+Person[i-1].study;
			}
			if (Person[i-1].type="extro"){
				localHappinessExtro<-localHappinessExtro+Person[i-1].happy;
				localLonelinessExtro<-localLonelinessExtro+Person[i-1].lonely;
				localGradeExtro<-localGradeExtro+Person[i-1].study;
			}
			if (Person[i-1].type="rebel"){
				localHappinessRebel<-localHappinessRebel+Person[i-1].happy;
				localLonelinessRebel<-localLonelinessRebel+Person[i-1].lonely;
				localGradeRebel<-localGradeRebel+Person[i-1].study;
			}
			if (Person[i-1].type="playboy"){
				localHappinessPlayboy<-localHappinessPlayboy+Person[i-1].happy;
				localLonelinessPlayboy<-localLonelinessPlayboy+Person[i-1].lonely;
				localGradePlayboy<-localGradePlayboy+Person[i-1].study;
			}
			if (Person[i-1].type="teacher"){
				localHappinessTeacher<-localHappinessTeacher+Person[i-1].happy;
				localLonelinessTeacher<-localLonelinessTeacher+Person[i-1].lonely;
//				localGradeIntro<-localGradeIntro+Person[i-1].study;
			}
			
		}
		globalIntro<-localHappinessIntro/numberOfExtro;
		globalExtro<-localHappinessExtro/numberOfIntro;
		globalRebel<-localHappinessRebel/numberOfRebel;
		globalPlayboy<-localHappinessPlayboy/numberOfPlayboy;
		globalTeacher<-localHappinessTeacher/numberOfTeacher;
		
		globalIntro_study<-localGradeIntro/numberOfExtro;
		globalExtro_study<-localGradeExtro/numberOfIntro;
		globalRebel_study<-localGradeRebel/numberOfRebel;
		globalPlayboy_study<-localGradePlayboy/numberOfPlayboy;
//		globalTeacher_study<-localGradeTeacher/numberOfTeacher;
		
//		write("Intro happiness: " + globalIntro);
//		write("Extro happiness: " + globalExtro);
//		write("Extro loneliness: " + localLonelinessExtro/numberOfIntro);
//		write("Rebel happiness: " + globalRebel);
//		write("Playboy happiness: " + globalPlayboy);
//		write("Teacher happiness: " + globalTeacher);
//		write("Number of calls: " + numberOfCalls);
		
		
	}
}

species Office{
	int size<-5;
	aspect base{
		draw circle(size) color: rgb("black") wireframe: true;
		draw circle(2) color: rgb("tan");
	}
	
}

species Club{
	string name<-nil;
	int size<-10;
	
	int oopa_loompa<-100;
	bool fun<-false;
	int funvalue<-rnd(200,255);
	list<Person> peoplePresent <- [];
	

	
	aspect base{
//		draw square(size) color: rgb("black") wireframe: true;
//		draw square(3) color: rgb("yellow");
		if oopa_loompa<100 and fun=false{
			draw square(size+0.5) color: rgb(oopa_loompa/2, 70, funvalue-oopa_loompa) wireframe: true;
			draw square(2) color: rgb(funvalue-oopa_loompa, 70, oopa_loompa/2);
			oopa_loompa<-oopa_loompa+20;
		}
		else{
			fun<-true;
			draw square(size+0.5) color: rgb(oopa_loompa/2, 70, funvalue-oopa_loompa) wireframe: true;
			draw square(3) color: rgb(funvalue-oopa_loompa, 70, oopa_loompa/2);
			oopa_loompa<-oopa_loompa-20;
			if oopa_loompa<50{fun<-false;}
		}
	}
	
	reflex check_density{
		ask Person{
			if (!(myself.peoplePresent contains self)){
				if self.readyToInteract{//and self.hasTargetClub 
					if self.location distance_to myself.location < myself.size{
						myself.peoplePresent[0] +<- self;
					}
				
				
				}
			}
		}
		//WHEN PEOPLEPRESENT>15, CONSIDER IT PACKED, NO MORE ENTRY;
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
//			loop while: (tries_to_get_playboy<3 and p1.type!="playboy" ){
//				p1 <- one_of(peoplePresent);
//				tries_to_get_playboy<-tries_to_get_playboy+1;	
//			}
			peoplePresent >- p1;
			Person p2 <- one_of(peoplePresent);
			peoplePresent >- p2;
			
			if (p1.type>p2.type){
				Person p3 <- nil;
				p3<-p1;
				p1<-p2;
				p2<-p3;
			}
//			write("p1.lonely="+p1.wanna_interactWith_plby);
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
//				else if (p2.type="playboy") and p1.wanna_interactWith_plby=true{
//					//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +6 happiness with an extro.
//						p1.happy<-p1.happy+5;
//						p2.happy<-p2.happy+6;
//						write(p1.name+" lonly=10///////////////////////////////////////////////");
//						ask p1{
//							self.readyToInteract<-false;
//							self.lonely<-0;
//							write(p1.name+" lonelyness:"+self.lonely+" "+p1.lonely);
//						}
//						ask p2{
//							self.readyToInteract<-false;
//						}
//						p1.wanna_interactWith_plby<-false;
//						
//						//write (p1.name + " got good with " + p2.name);
//					
//				}
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
						p2.happy<-p2.happy+5;
						
						ask p1{
							self.readyToInteract<-false;
						}
						ask p2{
							self.readyToInteract<-false;
						}
						
						//write (p1.name + " got traumatised by " + p2.name);
				}
//				else if (p2.type="playboy") and p1.wanna_interactWith_plby=true{
//					//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +3 happiness with an intro.
//						p1.happy<-p1.happy+5;
//						p2.happy<-p2.happy+3;
//						ask p1{
//							self.readyToInteract<-false;
//							self.lonely<-0;
//						}
//						ask p2{
//							self.readyToInteract<-false;
//						}
//						p1.wanna_interactWith_plby<-false;
//						//write (p1.name + " got good with " + p2.name);
//					
//				}
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
			else if (p1.type="playboy"){
//				if (p2.type="rebel"){
//					//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +5 happiness with a rebel.
//						p1.happy<-p1.happy+5;
//						p2.happy<-p2.happy+5;
//						
//						ask p1{
//							self.readyToInteract<-false;
//						}
//						ask p2{
//							self.lonely<-0;
//							self.readyToInteract<-false;
//						}
//						
//						//write (p1.name + " got good with " + p2.name);
//					
//				}
				if (p2.type="playboy"){
					//////
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

species Lib{
	string Name<-nil;
	int size<-15;
	int density<-0;
	int temp_ctdn<-20;
	
	list<Person> peoplePresent <- [];
	

	
	aspect base{
		draw square(size+1) color: rgb("black") wireframe: true;
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
				else if (p2.type="playboy") {
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
	Person my_plby<-nil;
	int timeSpentInLibrary;
	int timeSpentInClub<-0;
	rgb agentColor<-rgb("green");
	float view_dist<-5.0;
	list<Person> friends<-[];
	list<Person> near_plbys<-[];
	int happy <- 90;
	int study <- 50;
	int avoid <- nil;
	int lonely <- 0;
	int generous <- nil;
	int mayhem <- nil;
	int friendly<-nil;
	int awkward<-nil;
	int smart <- nil;
	Club my_club<-nil;
	bool am_at_club<-false;
	bool am_at_library<-false;
	bool am_at_office<-false;
	bool choose_bt_club_and_lib<-false;
//	bool wanna_interactWith_plby<-false;
	bool plby_nearby<-has_belief_op(self,plby_near);
	bool on_my_way<-false;
	aspect base{
		
		draw circle(1) color: agentColor;
	}
	
	action setUp(string typeLocal,int i){
		name<-typeLocal+i;
		type<-typeLocal;
		my_club<-TheClub[int(rnd(length(TheClub)-1))];
		do add_desire(STUDY_WELL);
		
		if (type="intro"){
			study <- rnd(1,100);
			avoid <- rnd(50,100);
			lonely <- rnd(40,70);
			
			agentColor<-rgb("pink");	
		}
		else if (type="extro"){
				study <- rnd(1,100);
				generous <- rnd(50,100);
				lonely <- rnd(20,30);
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
			lonely<-rnd(10,30);
			agentColor<-rgb("green");
		}
		
	}
//	rule belief:plby_near_and_lonely new_desire: FIND_PLBY strength:4.0; 
	rule belief: am_happy new_desire: STUDY_WELL strength:2.0;
	rule belief: not_happy new_desire: BE_HAPPY strength: 3.0;
	rule belief: too_lonely new_desire: FIND_PLBY strength: 5.0;
//	rule belief: too

	perceive target:Person where (each.type="playboy") in: view_dist {
        focus id:plby_at_location;
        
    	if self.type="playboy" and (!(myself.near_plbys contains self)) {
    		myself.near_plbys[0]+<-self;
    	}
        
        ask myself{
	    	if length(near_plbys)!=0{	
//	    		write(name+" nearby_plbys "+near_plbys);
	    		do add_belief(plby_near);}
	    	else{
	    		do remove_belief(plby_near);}
	    	
	    }
//				do remove_intention(STUDY_WELL, false);
	    
    }
    

 
	action callAll{
		loop i from:1 to: 20{
			write(Person[i-1].name);
		}
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
		
//		write(name+" lonely "+lonely+" happy "+happy+" grade "+study);
	}
	reflex lonely_Check {
		if (type != "playboy"){
			bool loneliness<-flip(0.1);
//			plby_nearby<-has_belief_op(self,plby_near);
			if loneliness {lonely<-lonely+1;}
			if (lonely>70){
				write(name + " too lonely");
				do remove_intention(STUDY_WELL,false);
				do remove_intention(BE_HAPPY,false);
				do add_belief(too_lonely);
				do add_intention(FIND_PLBY);
				bool lonely_makes_unhappy<-flip(0.5);
				if lonely_makes_unhappy{happy<-happy-1;}
			}
			else{
//			wanna_interactWith_plby<-false;
				do remove_belief(too_lonely);
				do remove_intention(FIND_PLBY,false);
//				do add_intention(STUDY_WELL);
				
				if happy<30{
						do remove_belief(am_happy);
						do add_belief(not_happy);
						do remove_intention(STUDY_WELL,false);	
						do add_intention(BE_HAPPY);
					}
				else if happy>70{
						do remove_belief(not_happy);
						do add_belief(am_happy);
						do remove_intention(BE_HAPPY,false);
						do add_intention(STUDY_WELL);
						choose_bt_club_and_lib<-false;
						
					}
				}
			
		}
		else{
			do remove_intention(FIND_PLBY);
			if happy<30{
					do remove_belief(am_happy);
					if !(has_belief_op(self,not_happy)){
						do add_belief(not_happy);}
					do remove_intention(STUDY_WELL,false);
					
					do add_intention(BE_HAPPY);
				}
			else if happy>70{
					do remove_belief(not_happy);
					if !(has_belief_op(self,am_happy)){
						do add_belief(am_happy);}
					do remove_intention(BE_HAPPY,true);
					do add_intention(STUDY_WELL);
					
				}
		}
		
	}
//	reflex target_clubs_renewal{
//		if (timeSpentInClub mod 100000)=0 and !am_at_club and on_my_way=false{
//			TheClub<-Club[int(rnd(length(Club)-1))];
//		}
//	}
	
	reflex check_if_at_clubs_or_libs{
		ask Club{
			if (self.location distance_to myself.location) <self.size{
				myself.am_at_club<-true;
				break;
			}
			else {myself.am_at_club<-false;}
		}
		if am_at_club {
			if happy<90{
				happy<-happy+1;
			}
			
			
		}
		///////////////////////////////////////////////////////
//		if has_intention_op(self,FIND_PLBY){
//			write(name+"yes plby");
//			
//		}
//		if has_intention_op(self,BE_HAPPY){
//			write(name+"yeah be happy");
//		}
//		if has_intention_op(self,STUDY_WELL){
//			write(name+"yeah study");
//		}
		/////////////////////////////////////////////////////
		ask Lib {
			if (self.location distance_to myself.location)<self.size{
				myself.am_at_library<-true;
				break;
			}
			else{myself.am_at_library<-false;}
		}
		ask Office {
			if (self.location distance_to myself.location)<self.size{
				myself.am_at_office<-true;
				break;
			}
			else{myself.am_at_office<-false;}
		}
		if am_at_library and type!="teacher"{
			bool grade_plus<-flip(0.5);
				if grade_plus{
					study<-study+1;
				}
				else{
					happy<-happy-1;}
			if type="playboy"{
				happy<-happy-1;	
//				write("playboy at lib?!");
			}
		}
		else if am_at_library=false and type!="teacher"{
			bool grade_minus<-flip(0.5);
			if grade_minus{
				study<-study-1;
			}
		}
		else if am_at_library and type="teacher"{
			happy<-happy+1;
		}
		if am_at_office and type="teacher"{
			bool work_pressure<-flip(rnd(1));
			if work_pressure{happy<-happy-1;}
		}
		
	}
	plan find_clubs intention:BE_HAPPY{
			bool temp_choose<-flip(rnd(1));
			if type="teacher" {
				if !am_at_club and !am_at_library{
					if choose_bt_club_and_lib=false{
						choose_bt_club_and_lib<-true;
						if temp_choose{ 
							targetLocation<-TheLibrary.location;
							write(name + " "+"going to library to see my students");
						}
						else{
							targetLocation<-my_club.location;
							write(name + " "+"going to clubs for fun");
						}
					}
				}
				else{
	//				targetLocation<-TheOffice.location;
					do wander speed:2.0;
	//				targetLocation<-nil;
				}
				
			}
			else{
				if !am_at_club {
					targetLocation<-my_club.location;write(name + " "+"going to clubs for fun");
				}
				else{
					do wander speed:2.0;
				}
			}
			
			
	}
	plan goto_plby_at_clubs_when_lonely intention:FIND_PLBY{
			
			targetLocation<-my_club.location;
			write(name + " "+"going to clubs for plbys");
			plby_nearby<-has_belief_op(self,plby_near);
			if plby_nearby and am_at_club{//already in a club
				write(name+" plby_nearby");
//				wanna_interactWith_plby<-true; // and wanna_interactWith_plby=true
				if (type!="playboy"){
				
					Person plby_target<-nil;
					loop i from:0 to:length(near_plbys)-1{
						Person plby_temp <- near_plbys[i];
//						write("plby_temp:"+plby_temp.name);
						if (plby_temp.location distance_to location)<view_dist{
							plby_target<-plby_temp;
							
							write(name+" target: "+plby_target);
							break;
						}
					}
	//				do goto target:plby_target;
					if plby_target!=nil{
						write(name+" ready to interact with "+plby_target.name);
						if type="extro" {
							//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +6 happiness with an extro.
								happy<-happy+5;
								plby_target.happy<-plby_target.happy+6;
								//write (p1.name + " got good with " + p2.name);
						}
						else if type="intro"{
							
						//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +3 happiness with an intro.
							happy<-happy+5;
							plby_target.happy<-plby_target.happy+3;
							//write (p1.name + " got good with " + p2.name);
						}
						else if (type="rebel"){
							//SCNEARIO a person gets happy if they meet a playboy. a playboy gets a constant +5 happiness with a rebel.
								happy<-happy+5;
								plby_target.happy<-plby_target.happy+5;
								//write (p1.name + " got good with " + p2.name);
						}
						else if (type="teacher"){
							bool chance_to_shy <- flip(awkward/100);
							
							if (chance_to_shy){
								happy<-happy-5;
								plby_target.happy<-plby_target.happy-5;
								
							}
							else{
								happy<-happy+5;
								plby_target.happy<-plby_target.happy+5;
							}
							
								
								//write (p1.name + " got good with " + p2.name );
						
						}
						lonely<-10;
						write(name+" lonely=0///////////////////////////////////////////////");
						do remove_intention(FIND_PLBY,false);
//						do remove_belief(too_lonely);
					}
				}
			}
			
//			else if (location distance_to my_club.location) > distanceThreshhold{
////				do move_to_target;
//			}
//			else{
//				do wander speed:2.0;
//			}

			
	}
	
	plan go_study_when_happy_and_not_lonely intention:STUDY_WELL{
			if type!="teacher"{
				targetLocation<-TheLibrary.location;
//				do move_to_target;
			}
			else{
				targetLocation<-TheOffice.location;
//				do wander speed:2.0;
				}
			
	} 
	
	

	
	action start_call{
		write("Starting call");
		Person target<-one_of(friends);
		do start_conversation to: list(target) protocol:'fipa-contract-net' performative: 'inform' contents: ["How do u do I need to talk",target];
		
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
		
	
	
//	reflex move_to_library when:(hasTargetLibrary) {
//		speed <- 5.0;
//		if (self.location distance_to targetLocation)>distanceThreshhold{
//			do goto target: targetLocation;
////			timeSpentInLibrary<-0;
//			
//		}
////		else{
////			//agentColor<-rgb("pink");
////			timeSpentInLibrary<-timeSpentInLibrary+1;
////		}
//		
//	}
	

	reflex move_to_target when:(targetLocation!=nil){
		if (self.location distance_to targetLocation)>distanceThreshhold/5{
			do goto target: targetLocation speed:2.0;
			on_my_way<-true;
		}
		else{
			do wander speed:2.0;
			on_my_way<-false;
		}
	}
	
//	reflex time_to_leave_lib when:timeSpentInLibrary>6{
//		hasTargetLibrary<-false;
//	}
//	
//	reflex time_to_leave_club when: timeSpentInClub>10{
//		hasTargetClub<-false;
//	}

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
//	reflex delay_between_interactions when:readyToInteract=false{
//		if type="playboy"{
//			readyToInteract<-true;
//		}
//		else if (delayCounter<5){
//			delayCounter<-delayCounter+1;
//		}
//		else{
//			if delayCounter<10{
//				delayCounter<-delayCounter+1;
//				readyToInteract<-true;
//			}
//			else{
//				delayCounter<-0;
//			}
//			//write(name + "is ready to interact");
//			
//		}
//	}
		
}




experiment myExperiment type:gui{
	output{
		display myDisplay {
			species Person aspect:base;
			species Lib aspect:base;
			species Club aspect:base;
			species Office aspect:base;
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
		display chart3 type: 2d {
			chart "Individual Grades" type: series {
        	data "Intro Grade" value: globalIntro_study color: #pink;
        	data "Extro Grades" value: globalExtro_study color: #blue;
        	data "Rebel Grades" value: globalRebel_study color: #black;
        	data "Playboy Grades" value: globalPlayboy_study color: #orange;
//        	data "Teacher Grades" value: globalTeacher_study color: #green;
    }
		}
    }
	
}