/**
* Name: Festival
* Based on the internal empty template. 
* Author: karl
* Tags: 
*/

model Festival
 
/* Insert your model definition here */
global {
	int numberOfPeople <- 100;
	int numberOfStores <- 10;	
	int distanceThreshould <- 5;
	//Centre InfoCentre;
//	Store targetstore;
	init {
		create Person number:numberOfPeople;
		create Store number:numberOfStores-1;
		create Centre ;
		create Stage number:5;
 
		loop counter from:1 to: numberOfPeople {
			Person guest <- Person[counter-1];
			guest <- guest.setName(counter);
		}
		loop counter from:1 to: numberOfStores-1{
			Store fishNchips <-Store[counter-1];
			fishNchips<-fishNchips.setName(counter);
		}
		
		Centre InfoCentre <- Centre[0];
//		InfoCentre<-InfoCentre.setName()
	}
}
 
species Person skills:[moving,fipa]{
	int is_hungry  <- int(rnd(50,100));
	int is_thursty <- int(rnd(50,100));
	string personName <- "Unknown";
	point InfoLocation <-nil;
	Store TargetStore <-nil;
	bool got_target<- false;
	list visited_stores;
 	point current_loc;
 	float total_dist<-0.0;
 	float temp_dist<-0.0;
 	int hungry_thirsty_time_count<-0;
 	
 	float lightShowInterest <- rnd(10,99)/100;
 	float speakerInterest <- rnd(10,99)/100;
 	float musicStyleInterest <- rnd(10,99)/100;
 	float maxUtilityScore <- 0.0;
 	point targetStageLocation <- nil;
 	bool atStage <- false;
 	bool goingToStage <- false;
 	//to delete
 	bool notInAuction<-true;
 	point auctLocation<-nil;
 
	aspect base{
		rgb agentColor <- rgb("green");
		if (is_hungry=0 and is_thursty>0) {
			agentColor <- rgb("pink");} 
		else if(is_hungry>0 and is_thursty=0){
			agentColor <- rgb("blue");			}
		else if(is_hungry=0 and is_thursty=0){
			agentColor <- rgb("red");}
		else{
			agentColor <- rgb("green");}
			
		
		draw circle(1) color: agentColor;
		
		
		
	}
	
	
	action setName(int num) {
		personName <-"Guest"+num;
	}
	Person giveInfo {
		return self;
	}
	reflex hunger_or_thursty when:(is_hungry>0 and is_thursty>0){
		if (is_hungry>0){is_hungry <- is_hungry-1;}
		if (is_thursty>0){is_thursty <- is_thursty-1;}
 
	}
	reflex move_Random when:(is_hungry>0 and is_thursty>0) and !goingToStage{
//		float speed <- 20.0;
		do wander speed:10.0;
		got_target<-false;
		current_loc<-self.location;
		if temp_dist!=total_dist{
			write("current_total_dist="+total_dist);
			temp_dist<-total_dist;
			hungry_thirsty_time_count<-hungry_thirsty_time_count+1;
			write( string(hungry_thirsty_time_count) +" time got hungry/thirsty");
		}
	}
	reflex move_to_centre when:((is_hungry=0 or is_thursty=0)and !got_target and !goingToStage){
//		point Centre_location<-InfoCentre.location;
//			if ((self distance_to Centre_location) > distanceThreshould){
			speed <- 5.0;
			ask Centre{myself.InfoLocation<-self.location;}
			if (self.location distance_to InfoLocation)>distanceThreshould{
				do goto target: InfoLocation;
				}
			else{
				total_dist<-total_dist+(current_loc distance_to InfoLocation);
//				write("current_total_distance_at_INFO_CENTRE="+total_dist);
				ask Centre{myself.TargetStore<-self.giveInfo(myself);}
				if TargetStore != nil{
					got_target<-true;
				}
				write(TargetStore);
				}
	}
	reflex move_to_target when:((is_hungry=0 or is_thursty=0) and got_target and !goingToStage) {
		speed <- 5.0;
		bool notSatisfied<-true;
		if (self.TargetStore != nil){
			if (self.location distance_to TargetStore.location)>distanceThreshould{
				do goto target: TargetStore.location;}
			else{
				total_dist<-total_dist+(current_loc distance_to TargetStore.location);
	//			write("current_total_distance="+total_dist);
				if is_hungry=0{
					bool boughtFood<- false;
					ask TargetStore{boughtFood <- sellFood();}
					if (boughtFood){
						is_hungry<-int(rnd(50,100));	
					}
					else{
						notSatisfied<-true;
					}
	 
				}
				if is_thursty=0{
					bool boughtDrink <- false;
					ask TargetStore{boughtDrink <- sellDrink();}
					if (boughtDrink){
						is_thursty<-int(rnd(50,100));
					}
					else{
					notSatisfied<-true;
					}
	 
				}
	 			if (notSatisfied){
	 				do goto target:InfoLocation;
	 				got_target<-false;
	 			}
			}
			
		}
	}
	
	reflex move_to_stage when: targetStageLocation != nil{
		speed<-5.0;
		goingToStage<-true;
		if (self.location distance_to targetStageLocation > 10){
			do goto target: targetStageLocation;
		}
		else{
			atStage<-true;
		}
	}
	
	
	reflex receiveCalls when: !empty(cfps){

		bool wantsToParticipate<-flip(0.5);
		loop cfpMsg over: cfps{
			if cfpMsg.contents[0] = 'End'{
				notInAuction<-true;
			}
			else{
				write name + ' receives a cfp msg from ' + agent(cfpMsg.sender).name + ' with text ' + cfpMsg.contents;
				string dummy<-cfpMsg.contents[0];
				auctLocation<-cfpMsg.contents[1];
				
				//int proposedPrice<-cfpMsg.contents[1];
			
				if (!wantsToParticipate){
					do refuse message: cfpMsg contents: ["Dont want to" + name];
				}
				else{
					notInAuction<-false;
		//			speed<-100.0;
		//			do goto target:InfoLocation;
					do propose message: cfpMsg contents: ["Oke" + name];
				}
			}
		
		}
	}
	
	reflex receiveApproveProposals when: !empty(accept_proposals){
		loop acceptMsg over: accept_proposals{
			do inform message:acceptMsg contents:[name + " accepts"];
			string dummy <-acceptMsg.contents;
		}
	}
	
	reflex receiveRejectProposals when: !empty(reject_proposals){
		loop rejectMsg over: reject_proposals{
		}
	}
	
	reflex receiveEndInforms when: !empty(proposes){
		
		loop msg over:proposes{
			string dummy <-msg.contents[0];
			write(dummy);
			if dummy='End'{
				write("wbh");
				targetStageLocation<-nil;
				goingToStage<-false;
				atStage<-false;
			}
		}
		
	}
	
	reflex receiveInforms when: !empty(informs){
			message msg;
			
			loop informMsg over: informs{
				float light <- informMsg.contents[0];
				float speaker <- informMsg.contents[1];
				float music <- informMsg.contents[2];
				point currentStageLocation <- informMsg.contents[3];
				
				
				
				float currentScore <- light*lightShowInterest + speaker*speakerInterest + music*musicStyleInterest;
				write (currentScore);
				write (maxUtilityScore);
				if (currentScore>maxUtilityScore){
						
					maxUtilityScore<-currentScore;
					targetStageLocation<-currentStageLocation;
					msg<-informMsg;
					
				}
				//write (currentScore);
				
			}
			//write(maxUtilityScore);
			//write(targetStageLocation);
			
			do propose message: msg contents: ["Oke"];
			
	}
	
	reflex receiveAgrees when: !empty(agrees){
		message msgAgree <- agrees[0];
		write (name + " won the auction");
		do end_conversation message:msgAgree contents:["End"];
	}

}

species Stage skills:[fipa]{
	float lightShow <- rnd(10,99)/100;
	float speaker <- rnd(10,99)/100;
	float musicStyle <- rnd(10,99)/100;
	int showLength <- rnd(10,40);
	list <Person> fans <- [];
	
	aspect base{
		
		draw square(5) color: rgb("pink");
		
 
	}
	
	reflex sendInfoToPeople when: time=3{

		do start_conversation to: list(Person) protocol:'no-protocol' performative: 'inform' contents: [lightShow, speaker, musicStyle, location];
		
	}
	
	reflex receiveProposals when: !empty(proposes){
		
		
		loop proposeMsg over: proposes {
			fans[0]+<-agent(proposeMsg.sender);
			string dummy <- proposeMsg.contents;
			
			}
		
		
	}
	
	reflex sendEndInfoToPeople when: time=3+showLength{
		if fans != []{
			do start_conversation to: fans protocol:'no-protocol' performative: 'propose' contents: ['End'];
		
		}
		
	}
	
	
	
	
	
}

species Auctioneer skills:[fipa]{
	string auctName <- "undefined";
	string currentItem <- "undefined";
	list<string> items <- ["Brush","Car","Pen","Goldbar","Laptop"];
	int currentItemIndex;
	int currentPrice;
	int minimumThreshhold;
	bool startAuction<-false;
	bool startRealAuction<-false;
	list<Person> bidders <- [];
	bool realAuctionAlreadyStarted<-false;
	bool auctionFinished<-true;
	float startTime<-time;
	bool endingBid<-false;
	bool visible<-true;
	int auctTime<-100;
	int endAuctTime<-0;
	
	aspect base{
		rgb agentColor <- rgb("brown");
		
		if (visible){
			draw circle(5) color: agentColor;	
		}
		else{
			draw circle(5) color: rgb("white");
		}
 
	}
	
	action createItem{
		currentItemIndex<-rnd(0,4);
		currentItem <- items[currentItemIndex];
		currentPrice <- rnd(1000,1500);
		minimumThreshhold <- currentPrice - 600;
	}
	
	reflex sendProposalToBidders when: startAuction=false{
		visible<-true;
		auctionFinished<-false;
		write ("Conversation initiated");
		do createItem;
		do start_conversation to: list(Person) protocol:'fipa-contract-net' performative: 'cfp' contents: ['Hello people! Who wants to join the auction?',location];
		startAuction<-true;
		startTime<-time;
	}
	
	reflex endBid when: endingBid=true{
		write ("Conversation ending now.");
		do start_conversation to: list(bidders) protocol:'fipa-contract-net' performative: 'cfp' contents: ['End'];
		endingBid<-false;
		visible<-false;
		endAuctTime<-time;
		auctTime<-endAuctTime+rnd(10,30);
	}

	
	reflex receiveRefuseMessages when: !empty(refuses) and startRealAuction=false{
		loop refuseMsg over: refuses{
			write agent(refuseMsg.sender).name + ' refused.';
			string dummy <- refuseMsg.contents[0];
		}
	}
	
	reflex receiveProposals when: !empty(proposes){
		//Waits for ppl to get close
		if time>startTime+10{
			loop proposeMsg over: proposes {
				do accept_proposal message: proposeMsg contents: ["Accepted."];
				write "Accepting";
				bidders[0]+<-agent(proposeMsg.sender);
				string dummy <- proposeMsg.contents;
				startRealAuction<-true;
			}
		}
		
	}
	
	reflex startAuctioning when: startRealAuction=true and realAuctionAlreadyStarted=false{
		realAuctionAlreadyStarted<-true;
		do createItem;
		do start_conversation to: list(bidders) protocol:'no-protocol' performative: 'inform' contents: ['Current price for: ', currentItem, currentPrice];
	}
	
	
	reflex receiveMessages when: auctionFinished=false {
		if !empty(refuses) and empty(agrees){
			loop aux over:refuses{
				string dummy<-aux.contents;
				write(dummy);
			}
			currentPrice<-currentPrice-100;
			if currentPrice<minimumThreshhold{
				write("Auction ended. I can't go any lower than this.");
				endingBid<-true;
			}
			else{
			do start_conversation to: list(bidders) protocol:'no-protocol' performative: 'inform' contents: ['Current price for: ', currentItem, currentPrice];
			}
		
		}
		else if !empty(agrees){
			loop aux over:refuses{
				string dummy<-aux.contents;
				write(dummy);
			}
			loop answer over:agrees{
				if !auctionFinished{
					write agent(answer.sender).name + " agreed";
					endingBid<-true;
					do agree message:answer contents:["wp"];
				}
				string dummy <- answer.contents;
				auctionFinished<-true;
		}
		}
	}
	
	reflex auctionTime{
		
		if time=auctTime{
			startAuction<-false;
			startRealAuction<-false;
			bidders <- [];
			realAuctionAlreadyStarted<-false;
			auctionFinished<-true;
		}
	}
	
}
 
species Store{
 
	bool hasFood <- true;
	bool hasDrink <- true;
	int foodSupplies <- rnd(3,5);
	int drinkSupplies <- rnd(3,5);
	string storeName <- "undefined";
	bool resupply <-false;
	Person personNear <-nil;
	int resupplyCountdown <-30; 
	action setName(int num){
		storeName <- "Store Numero " + num;
	}
 
	bool sellDrink{
		if(drinkSupplies > 0){
			drinkSupplies <- drinkSupplies -1;
			write(storeName + "sold drink");
			return true;	
		}
		else{
			write("Sowwy no more drinkies");
			return false;
		}
 
	}
	bool sellFood{
		if (foodSupplies > 0){
			foodSupplies <- foodSupplies -1;
			write(storeName + " sold food");
			return true;
		}
		else{
			write("Sowwy no more foodies");
			return false;
		}
	}
 
	reflex{
		if ((foodSupplies=0 or drinkSupplies=0)and resupply=false){ 
			if resupplyCountdown=0{
				resupply<-true;
				resupplyCountdown<-10;
			}
			else{
				resupplyCountdown<-resupplyCountdown-1;
			}
		} 
		if (resupply){
			write("RESUPPLY TIME FOR " + storeName);
			if (foodSupplies=0){
				foodSupplies <- rnd(1,5);}
			if (drinkSupplies=0){
				drinkSupplies <- rnd(1,5);}
			resupply<-false;
		}
	}
 
	reflex{
		if (drinkSupplies=0){
			write("No more drinks for " + storeName);
			hasDrink<-false;
		}
		else{
			hasDrink<-true;
		}
 
		if (foodSupplies=0){
			write("No more food for " + storeName);
			hasFood<-false;
		}
		else{
			hasFood<-true;
		}
	}
 
 
	aspect base {
		rgb agentColor <- rgb("black");
 
		if (hasFood and hasDrink){
			agentColor <- rgb("yellow");
		}
		else if (hasFood){
			agentColor <- rgb("pink");
		}
		else if (hasDrink){
			agentColor <- rgb("blue");
		}
 
		draw square(2) color:agentColor;
	}
 
 
}
 
species Centre {
	Store giveInfo (Person p) {
 
        Store foundStore <- nil; // Apparently we cant return inside the ask so we use this as a temp variable
		list<Store> matchingStores <- [];
 
        if (p.is_hungry =0 and p.is_thursty =0) {
        	write("dying");
            ask Store {
 
            	if (! (p.visited_stores contains(self))){
	                if (self.hasFood and self.hasDrink) {
	                	//write(self);
	                	matchingStores[0] +<- self;
	                	//foundStore <- self;
	                	//break;
	                }
 
                }
            }
        }
        else if (p.is_hungry=0) {
            ask Store{
//            	write("burger!");
            	if (! (p.visited_stores contains(self))){
                if (self.hasFood) {
                	//write(self);
               		matchingStores[0] +<- self;
 
					//foundStore <- self;
                	//break;                
                	}
            	}
 
            }
        }
        else if (p.is_thursty=0) {
            ask Store{
//            	write("coke!");
            	if (! (p.visited_stores contains(self))){
                if (self.hasDrink) {
                	//write(self);
                	//foundStore <- self;
                	matchingStores[0] +<- self;
 
                	//break;
                }
 
                }
            }
        }
        if (matchingStores != []) {
    		Store temp<-nil;
    		float temp_dist<-0.0;
    		float dist<-100.0;
    		int closest<-0;
    		
    		loop i from:0 to:length(matchingStores)-1{
    			temp<-matchingStores[i];
				temp_dist<-(self.location distance_to temp.location);
				if temp_dist<dist{
						dist<-temp_dist;
						closest<-i;}	
			}
			foundStore <- matchingStores[closest];
		}
        return foundStore;
 
    }
    aspect base {
    	draw square(4) color:rgb("orange");
    }
}
 
 
experiment myExperiment type:gui{
	output{
		display myDisplay {
			species Store aspect:base;
			species Person aspect:base;
			species Centre aspect:base;
			species Stage aspect:base;
		}
	}
}