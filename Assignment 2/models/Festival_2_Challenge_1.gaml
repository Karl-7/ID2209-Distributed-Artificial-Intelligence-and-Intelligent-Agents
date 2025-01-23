/*
* Name: Festival
* Based on the internal empty template. 
* Author: karl
* Tags: 
*/
model Festival

/* Insert your model definition here */
global {
	int numberOfPeople <- 5;
	int numberOfStores <- 7;	
	int distanceThreshould <- 5;
	int numberOfActneers<-1;
	list item_type<-['watch','porcelains','my_brain'];//,'porcelains','my_brain'];
	list Aucters<-list_with(numberOfActneers,nil);
	int Auction_type<-0;//0:Dutch, 1: First-Price sealed;
	//Centre InfoCentre;
//	Store targetstore;
	init {
		create Person number:numberOfPeople;
		create Store number:numberOfStores;
		create Centre ;
//		create SecurityGuard;
		create Auctioneers number: numberOfActneers;
		
		loop counter from:1 to: numberOfPeople {
			Person guest <- Person[counter-1];
			guest <- guest.setPersonName(counter);
		}
		loop counter from:1 to: numberOfStores{
			Store fishNchips <-Store[counter-1];
			fishNchips<-fishNchips.setStoreName(counter-1);
		}
		loop counter from:1 to: numberOfActneers{
			Auctioneers Aucter<-Auctioneers[counter-1];
			Aucters[counter-1]<-Aucter;
			Aucter<-Aucter.setActName(counter-1);	
//			write(Aucters);
		}
		
		
		Centre InfoCentre <- Centre[0];
//		InfoCentre<-InfoCentre.setName()
	}
}

species Person skills:[moving,fipa]{
	int is_hungry  <- int(rnd(10,20));
	int is_thursty <- int(rnd(10,20));
	string personName <- "Unknown";
	point InfoLocation <-nil;
	Store TargetStore <-nil;
	Store MemoryTargetStore<-nil;
	bool got_target<- false;
	list visited_stores<-list_with(5,nil);
	bool fuckedUp <-false;
	bool alreadyCriminal <- false;
	bool knownCriminal <-false;
	int Forget_time<-15;
	int Forgets_countdown<-Forget_time;
 	point current_loc;
 	float total_dist<-0.0;
 	int hungry_thirsty_time_count<-0;
 	bool went_to_but_not_filled<-false;
 	string require<-'nothing';
	bool in_an_auction<-false;
 	int bid_price<-rnd(200,700);
 
 	
	aspect base{
		rgb agentColor <- rgb("green");
		if(in_an_auction=true){
			agentColor <- rgb("scarlet");}
		else{ 
			if (is_hungry=0 and is_thursty>0) {
				agentColor <- rgb("pink");} 
			else if(is_hungry>0 and is_thursty=0){
				agentColor <- rgb("blue");			}
			else if(is_hungry=0 and is_thursty=0){
				agentColor <- rgb("red");}		
			else{
				agentColor <- rgb("green");}
			}
		draw circle(1) color: agentColor;
		
	}
	action setPersonName(int num) {
		personName <-"Guest"+int(num);
	}
	action add_to_list (Store NewStore){
		loop i from: 1 to: length(visited_stores)-1{
			visited_stores[i-1]<- visited_stores[i];
			visited_stores[i]<-nil;}
		visited_stores[length(visited_stores)-1]<-NewStore;	
//		write(visited_stores);
	}
	Person giveInfo {
		return self;
	}
	reflex hunger_or_thursty when:(is_hungry>0 and is_thursty>0){
		if (is_hungry>0){is_hungry <- is_hungry-1;}
		if (is_thursty>0){is_thursty <- is_thursty-1;}
		got_target<-false;
		if Forgets_countdown!=0{
			Forgets_countdown<- Forgets_countdown-1;}
		else{
//			write("time to forget sth");
			do add_to_list (nil);
			Forgets_countdown<-Forget_time;
		}
	}
	reflex move_Random when:(is_hungry>0 and is_thursty>0) {
//		float speed <- 20.0;
		do wander speed:10.0;
//		got_target<-false;
		current_loc<-self.location;
	}
	reflex exploring_stores {
	
		Store temp_store<-nil;
		//using global list to check if passed to nearby store
		ask Store{
			if (myself.location distance_to self.location)<(distanceThreshould*3){
				if int(last_index_of(myself.visited_stores,self))=-1{
//					write(self.storeName + " is not in memory");
				}
				else{
//					write(self.storeName + " is at " + int(last_index_of(myself.visited_stores,self)));
				}
				if last_index_of(myself.visited_stores,self)!=length(myself.visited_stores)-1{
//					write("adding it to memory");
					temp_store<-self;
					
					}
			}
		}
		if temp_store!=nil{
			do add_to_list(temp_store);
		}
		
	
	}
	reflex go_with_memory when:(is_hungry=0 or is_thursty=0){
		
		if visited_stores[length(visited_stores)-1]!=nil{
			
			float dist<-100.0;
			float temp<-0.0;
			int closest<-0;
			Store temp_store<-nil;
			loop i from:length(visited_stores)-1 to:0{
				if visited_stores[i]!=nil{
					temp_store<-visited_stores[i];
					temp<-(self.location distance_to temp_store.location);
					if temp<dist{
						dist<-temp;
						closest<-i;}	
				}
			}
			
			MemoryTargetStore<-visited_stores[closest];
			
			
			if went_to_but_not_filled{
				do move_to_centre; 
			}
			else{
				went_to_but_not_filled<- move_to_target();
			}
			
		}
		else{
			current_loc<-self.location;
			do move_to_centre; 
		}
	}
	action move_to_centre{
//		point Centre_location<-InfoCentre.location;
//			if ((self distance_to Centre_location) > distanceThreshould){
			speed <- 1.0;
			ask Centre{myself.InfoLocation<-self.location;}
			if (self.location distance_to InfoLocation)>distanceThreshould{
				do goto target: InfoLocation;
				}
			else{
				went_to_but_not_filled<-false;
				total_dist<-total_dist+(current_loc distance_to InfoLocation);
//				write("current_total_distance_at_INFO_CENTRE="+total_dist);
				ask Centre{myself.TargetStore<-self.giveInfo(myself);}
				if TargetStore != nil{
					got_target<-true;
					}
//				write(TargetStore);
//				write("at centre");
				do add_to_list(TargetStore);
				}
				
	}
	bool move_to_target{
		if TargetStore=nil{
			TargetStore<-MemoryTargetStore;
		}
		speed <- 5.0;
		if (self.location distance_to TargetStore.location)>distanceThreshould{
			do goto target: TargetStore.location;
			return false;}
		else{
//			do add_to_list(TargetStore);
			
			total_dist<-total_dist+(current_loc distance_to TargetStore.location);
//			write("current_total_distance="+total_dist);
			if is_hungry=0{
				bool boughtFood<- false;
				
				ask TargetStore{boughtFood <- sellFood();}
				if (boughtFood){
					is_hungry<-int(rnd(5,10));	
				}
				else{
					
//					do goto target: InfoLocation;
					write("should_go_to info");
					return true;
				}
 
			}
			if is_thursty=0{
				bool boughtDrink <- false;
				ask TargetStore{boughtDrink <- sellDrink();}
				if (boughtDrink){
					is_thursty<-int(rnd(3,10));
				}
				else{
//					do goto target: InfoLocation;
					write("should_go_to info");
					return true;
				}
 
			}
 			TargetStore<-nil;
 			MemoryTargetStore<-nil;
			return false;
		}
	}
	reflex badThoughts{
		if (fuckedUp=false){
			fuckedUp <- flip(0.01);
			if fuckedUp{write personName + " fucked up";}
		}
		
		
	}
	
	reflex update_need when : (rnd(0,100) in [20,25]) and in_an_auction=false {
		require<-item_type[rnd(0,length(item_type)-1)];
		bid_price<-rnd(200,700);
		write("now "+personName+"  want a new "+require+", with $"+bid_price);
	}
	
	reflex receive_informs when: !empty(informs) and Auction_type=0{
		message informMsg<-informs[0];
		write("time"+time+' '+personName+' received a invite by '+agent(informMsg.sender).name+' : '+informMsg.contents);
//		write("okokokkokokokokokok"+string(informMsg.contents));
		if require in string(informMsg.contents[0]){
			do inform message:informMsg contents:['I\'m in'];
			in_an_auction<-true;
		}
		else {
			do refuse message: informMsg contents:['I pass'];
			in_an_auction<-false;
			do end_conversation message:informMsg contents:['end!'];
		}
		
	}
	reflex receiveAgrees when:!empty(agrees) and Auction_type=0{
//		message agreeMsg<-agrees[0];
		loop agreeMsg over:agrees{
			do end_conversation message:agreeMsg contents:['end!'];	
		}
	}
	
	reflex receiveCalls when: !empty(cfps) and Auction_type=0{
		loop cfpMsg over:cfps{
//			write("cfpMsg="+cfpMsg);
			if int(cfpMsg.contents[1])!=0{//normal 
				if int(cfpMsg.contents[1])<bid_price{
					do propose message:cfpMsg contents:[int(bid_price)];		
					write(personName+" say with $"+bid_price);	
					in_an_auction<-false;	
				}
				else {
					do refuse message: cfpMsg contents:['I pass'];
					write(personName+": for a "+require+"? What a rip off!!!");	
				}
			
			}
			else{//either a winner, or flaw
				if string(cfpMsg.contents[0])=personName{
					write(personName+": My precious, Mine!");
					in_an_auction<-false;
//					do end_conversation message:cfpMsg contents:['end!'];	
				}
				else{
					write(personName+": I need to rob a bank for that! come on!");
//					do end_conversation message:cfpMsg contents:['end!'];
					in_an_auction<-false;
				}
			}
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
	action setStoreName(int num){
		storeName <- "Store Numero " + num;
	}
	
	bool sellDrink{
		if(drinkSupplies > 0){
			drinkSupplies <- drinkSupplies -1;
//			write(storeName + "sold drink");
			return true;	
		}
		else{
//			write("Sowwy no more drinkies");
			return false;
		}
		
	}
	bool sellFood{
		if (foodSupplies > 0){
			foodSupplies <- foodSupplies -1;
//			write(storeName + " sold food");
			return true;
		}
		else{
//			write("Sowwy no more foodies");
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
//			write("RESUPPLY TIME FOR " + storeName);
			if (foodSupplies=0){
				foodSupplies <- rnd(1,5);}
			if (drinkSupplies=0){
				drinkSupplies <- rnd(1,5);}
			resupply<-false;
		}
	}
	
	reflex{
		if (drinkSupplies=0){
//			write("No more drinks for " + storeName);
			hasDrink<-false;
		}
		else{
			hasDrink<-true;
		}
		
		if (foodSupplies=0){
//			write("No more food for " + storeName);
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
	
	list<Person> badApples <- [];
	
	
	Store giveInfo (Person p) {

        Store foundStore <- nil; // Apparently we cant return inside the ask so we use this as a temp variable
		list<Store> matchingStores <- [];
		
		
        if (p.is_hungry =0 and p.is_thursty =0) {
        	//write("dying");
            ask Store {
            	
//            	if (! (p.visited_stores contains(self))){
	                if (self.hasFood and self.hasDrink) {
	                	//write(self);
	                	matchingStores[0] +<- self;
	                	//foundStore <- self;
	                	//break;
	                }
               
//                }
            }
        }
        else if (p.is_hungry=0) {
            ask Store{
//            	write("burger!");
//            	if (! (p.visited_stores contains(self))){
                if (self.hasFood) {
                	//write(self);
               		matchingStores[0] +<- self;
                	
					//foundStore <- self;
                	//break;                
                	}
//            	}
            
            }
        }
        else if (p.is_thursty=0) {
            ask Store{
//            	write("coke!");
//            	if (! (p.visited_stores contains(self))){
                if (self.hasDrink) {
                	//write(self);
                	//foundStore <- self;
                	matchingStores[0] +<- self;

                	//break;
                }
                
//                }
            }
        }
//        if (matchingStores != []) {
//    		foundStore <- one_of(matchingStores); // Selects a random store from the list
//    		//write(foundStore);
//		}
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
    
    reflex checkBehaviour{
    	
    	//Ill have to send a list of badApples to the Security guard, but probably ill have to send them one by one.
    	//So maybe this list should be for the whole species and in another reflex, whenever there is a bad apple , ill send it
    	ask Person {
    		if self.knownCriminal{
    			if self.alreadyCriminal=false{
//    				write (self.personName + " is criminal");
    				myself.badApples[0] +<- self;
    				self.alreadyCriminal<-true;
    			}
    		}
    	}
    	
    }
    reflex sendInfoToSecurity{
//    	write(badApples);
    	if badApples != []{
    		ask SecurityGuard{ if self.isFree{
	    		if self.location distance_to myself.location < 10{
	    			goingToCenter<-false;
	    			write(myself.badApples[0].personName + " is a target now");
	    			
	    			Person targetPerson <- myself.badApples[0];
	    			do onDuty(targetPerson);    			
	    			myself.badApples >- targetPerson;
	    			//remove from: myself.badApples[0];
    			}
    			else{
    				goingToCenter<-true;
    				speed<-10.0;
    				do goto target: myself.location;
    				write("John Cena to center");
    			}
    			
    		} 
    					
    		}
    	}
    }
    
    aspect base {
    	draw square(4) color:rgb("orange");
    }
}

species SecurityGuard skills:[moving] {
	string agentName <- "John Cena";
	bool isFree <- true;
	Person target <- nil;
	bool goingToCenter <- false;
	bool OnDuty<-false;
	bool Vivo<-false;
	action onDuty(Person p){
		target <- p;
		isFree <- false;
	}
	
	action kill(Person p){
		write (p.personName + "was tragically murdered by " + agentName);
		
		ask p {do die;}
	}
	//reflex in loc de action
	reflex chase when: isFree=false{
		Person p <- target;
		OnDuty<-true;
		speed <- 15.0;
		if (self.location distance_to p.location)>distanceThreshould{
			write ("going?");
			
			do goto target: p.location;}
		else{
			do kill(p);
			OnDuty<-false;
			isFree <- true;
			}
	
	}
	
	reflex move_Random when:(isFree and goingToCenter=false){
		speed <- 4.0;
		do wander;
	}
	
	aspect base {
		if OnDuty{
			if Vivo=false{
				draw triangle(4) color:rgb("red");
				Vivo<-true;
			}
			else{
				draw triangle(4) color:rgb("blue");
				Vivo<-false;
			}
		}
		else{
	    	draw triangle(4) color:rgb("black");
    	}
    }
	
}

species Auctioneers skills:[fipa]{
	string Actname<-nil;
	int time_to_sell<-rnd(50,100);
	bool auction_start<-false;
	string item;
	list crt_join_bidders<-list_with(numberOfPeople, nil);
	int member_idx<-0;
	int initial_price<-1000;
	int crt_price<-initial_price;
	list bidders;
	string winner<-nil;
	bool at_lowest_price<-false;

	
	
	
	reflex send_propose_message {
		if time_to_sell!=0{
			time_to_sell<-time_to_sell-1;
		}
		else{
			if  auction_start=false{
				do start_an_auction;
			}	
			time_to_sell<-rnd(50,100);
		}
	}
	action setActName(int num){
		Actname <- "AUCTION Nr." + num;
	}
	action start_an_auction{
		item<-item_type[rnd(0,length(item_type)-1)];	
		do start_conversation to: list(Person) protocol: 'no-protocol' performative:'inform' contents:["start aucting a "+item];	
	}
	action lower_price {
		write(Actname+": WTF No one wants this at $"+crt_price+"?!");
		if (crt_price-100)>350{
			crt_price<-crt_price-100;
			
		}
		else{
			at_lowest_price<-true;
		}
//		
//		do start_conversation to:list(bidders) protocol:'fipa-contract-net' performative:'cfp' contents:[item,crt_price];
	
		
	}
	action clean_up {
		loop proposeMsg over:proposes{
			Person GUEST<-proposeMsg.sender;
			if GUEST.personName!=winner{
				do reject_proposal message:proposeMsg contents:['sorry, Auction is over'];
//				do end_conversation message:proposeMsg contents:['end!'];
				write(Actname+" refused "+GUEST.personName+", and ended auction");
				
			}
			
		}
		//after finishing bid:
		member_idx<-0;
		crt_join_bidders<-list_with(numberOfPeople,nil);
		auction_start<-false;
		crt_price<-initial_price;
		at_lowest_price<-false;
		winner<-nil;
		time_to_sell<-rnd(50,100);
	
	}
	reflex receiveInforms when:!empty(informs){
		
		loop informMsg over: informs{
				Person GUEST<-informMsg.sender;
				write('allow bidder '+GUEST.personName+' to join '+Actname);
				do agree message:informMsg contents:['Agree to join'];
				crt_join_bidders[member_idx]<-GUEST;
				member_idx<-member_idx+1;
		}
		int first_nil<-crt_join_bidders index_of nil;
		if first_nil!=(-1){
			bidders<-copy_between(crt_join_bidders,0,first_nil);	
		}
		else{//everyone 
			bidders<-crt_join_bidders;
		}
		auction_start<-true;

	}
	reflex kick_out_refuses when: !empty(refuses){
		loop refuseMsg over: refuses{
			string dummy<-refuseMsg.contents[0];
		}
			
	}
	
	reflex sell_it when:!empty(proposes) and auction_start=true and Auction_type=0{// and no_winner=true
		
		int hiest_bid<-0;
//		write("tick!");
		loop proposeMsg over:proposes{
			Person GUEST<-proposeMsg.sender;
			hiest_bid<-int(proposeMsg.contents[0]);
			winner<-GUEST.personName;
			write(Actname+" winner is-----"+GUEST.personName+"!!!!!!!!!!!!!!!!!!");
			do accept_proposal message:proposeMsg contents:['Acceptable price'];
//			do agree message:proposeMsg contents:['Agree! sell!'];
			break;
		}
		write("//////////////////////////////////////////////////////////");
		write(Actname+":winner is "+winner+" with $"+hiest_bid);	
		write("//////////////////////////////////////////////////////////");
		
		

		
	}
	reflex actual_bidding when: Auction_type=0{// and no_winner=true
		if auction_start=true {
			if at_lowest_price=false and winner=nil{
				do lower_price;
				do start_conversation to:list(bidders) protocol:'fipa-contract-net' performative:'cfp' contents:[item,crt_price];
				
		
			}
			else if winner!=nil{
				do start_conversation to:list(bidders) protocol:'fipa-contract-net' performative:'cfp' contents:[winner,0];
				do clean_up;
			}
			else {// at lowest ptice, winner=nil
				do start_conversation to:list(bidders) protocol:'fipa-contract-net' performative:'cfp' contents:['ended',0];
				write("//////////////////////////////////////////////////////////");
				write("PRICE TOO LOW, "+Actname+" ENDED");
				write("//////////////////////////////////////////////////////////");
				do clean_up;
			}
		
		}
		
	}
	
	
	
	aspect base {
		rgb agentColor <- rgb("cyan");
		if auction_start{
			agentColor <- rgb("crimson");
		}
		else {
			agentColor <- rgb("cyan");
		}
		
		draw square(4) color:agentColor;
	}
	
	
	
}
	
	
	
experiment myExperiment type:gui{
	output{
		display myDisplay {
			species Store aspect:base;
			species Person aspect:base;
			species Centre aspect:base;
			species SecurityGuard aspect:base;
//			species Auctioneers aspect:base;
		}
	}
}