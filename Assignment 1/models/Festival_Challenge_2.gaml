/**
* Name: Festival
* Based on the internal empty template. 
* Author: karl
* Tags: 
*/

//Desired behaviour
//The person wanders around till hunger/thirst strikes him
//He goes to the info center
//Info cente gives him a random store that meets his needs
//Person goes to the store and buys what he needs
//IF he got hungry/thirsty on the way to the store, he will also TRY to buy that stuff
//However the store is not guaranteed to meet his wish, so if the store doesnt have the food/drink that he required ON HIS WAY to the store, he will go back to the info center

//TODO (maybe): if the person is hungry and thirsty, but there are no stores that have both, he'll still be sent to a random one
//I think the todo from above should be done after the challanges are finished.

model Festival

/* Insert your model definition here */
global {
	int numberOfPeople <- 10;
	int numberOfStores <- 7;	
	int distanceThreshould <- 5;
	//Centre InfoCentre;
//	Store targetstore;
	init {
		create Person number:numberOfPeople;
		create Store number:numberOfStores-1;
		create Centre ;
		create SecurityGuard;
		
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

species Person skills:[moving]{
	int is_hungry  <- int(rnd(10,20));
	int is_thursty <- int(rnd(10,20));
	string personName <- "Unknown";
	point InfoLocation <-nil;
	Store TargetStore <-nil;
	bool got_target<- false;
	list visited_stores;
	bool fuckedUp <-false;
	bool alreadyCriminal <- false;
	bool knownCriminal <-false;
	
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
	reflex move_Random when:(is_hungry>0 and is_thursty>0){
//		float speed <- 20.0;
		do wander speed:10.0;
		got_target<-false;
	}
	reflex move_to_centre when:((is_hungry=0 or is_thursty=0)and !got_target){
//		point Centre_location<-InfoCentre.location;
//			if ((self distance_to Centre_location) > distanceThreshould){
			speed <- 5.0;
			ask Centre{myself.InfoLocation<-self.location;}
			if (self.location distance_to InfoLocation)>distanceThreshould{
				do goto target: InfoLocation;
				}	
			else{
				ask Centre{myself.TargetStore<-self.giveInfo(myself);}
				if TargetStore != nil{
					got_target<-true;
				}
				//write(TargetStore);
				knownCriminal<-true;

				}
	}
	reflex move_to_target when:((is_hungry=0 or is_thursty=0) and got_target) {
		speed <- 5.0;
		if (self.location distance_to TargetStore.location)>distanceThreshould{
			do goto target: TargetStore.location;}
		else{
			if is_hungry=0{
				bool boughtFood<- false;
				ask TargetStore{boughtFood <- sellFood();}
				if (boughtFood){
					is_hungry<-int(rnd(5,10));	
				}
				else{
					do goto target: InfoLocation;
				}
				
			}
			if is_thursty=0{
				bool boughtDrink <- false;
				ask TargetStore{boughtDrink <- sellDrink();}
				if (boughtDrink){
					is_thursty<-int(rnd(3,10));
				}
				else{
					do goto target: InfoLocation;
				}
				
			}
			
		}
	}
	
	reflex badThoughts{
		if (fuckedUp=false){
			fuckedUp <- flip(0.1);
			if fuckedUp{write personName + " fucked up";}
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
	
	list<Person> badApples <- [];
	
	
	Store giveInfo (Person p) {

        Store foundStore <- nil; // Apparently we cant return inside the ask so we use this as a temp variable
		list<Store> matchingStores <- [];
		
		
        if (p.is_hungry =0 and p.is_thursty =0) {
        	//write("dying");
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
            	write("burger!");
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
            	write("coke!");
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
    				write (self.personName + " is criminal");
    				myself.badApples[0] +<- self;
    				self.alreadyCriminal<-true;
    			}
    		}
    	}
    	
    }
    reflex sendInfoToSecurity{
    	write(badApples);
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
		speed <- 15.0;
		if (self.location distance_to p.location)>distanceThreshould{
			write ("going?");
			do goto target: p.location;}
		else{
			do kill(p);
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


experiment myExperiment type:gui{
	output{
		display myDisplay {
			species Store aspect:base;
			species Person aspect:base;
			species Centre aspect:base;
			species SecurityGuard aspect:base;
		}
	}
}