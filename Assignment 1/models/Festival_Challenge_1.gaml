/*
* Name: Festival
* Based on the internal empty template. 
* Author: karl
* Tags: 
*/

model Festival
 
/* Insert your model definition here */
global {
	int numberOfPeople <- 10;
	int numberOfStores <- 7;	
	int distanceThreshould <- 5;
	list AllStores<-list_with(numberOfStores,nil);
	//Centre InfoCentre;
//	Store targetstore;
	init {
		create Person number:numberOfPeople;
		create Store number:numberOfStores;
		create Centre ;
 
		loop counter from:1 to: numberOfPeople {
			Person guest <- Person[counter-1];
			guest <- guest.setPersonName(counter);
		}
		loop counter from:1 to: numberOfStores{
			Store fishNchips <-Store[counter-1];
			fishNchips<-fishNchips.setStoreName(counter);
			AllStores[counter-1]<-Store[counter-1];
//			write(counter-1);
			
		}
		
		Centre InfoCentre <- Centre[0];
//		InfoCentre<-InfoCentre.setName()
	}
}
 
species Person skills:[moving]{
	int is_hungry  <- int(rnd(20,30));
	int is_thursty <- int(rnd(20,30));
	string personName <- "Unknown";
	point InfoLocation <-nil;
	Store MemoryTargetStore<-nil;
	Store TargetStore <-nil;
	bool got_target<- false;
	list visited_stores<-list_with(5,nil);
	int Forget_time<-15;
	int Forgets_countdown<-Forget_time;
 	point current_loc;
 	float total_dist<-0.0;
 	float temp_dist<-0.0;
 	int hungry_thirsty_time_count<-0;
 	bool went_to_but_not_filled<-false;
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
	action setPersonName(int num) {
		personName <-"Guest"+num;
	}
	action add_to_list (Store NewStore){
		loop i from: 1 to: length(visited_stores)-1{
			visited_stores[i-1]<- visited_stores[i];
			visited_stores[i]<-nil;}
		visited_stores[length(visited_stores)-1]<-NewStore;	
		write(visited_stores);
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
			write("time to forget sth");
			do add_to_list (nil);
			Forgets_countdown<-Forget_time;
		}
	}
	reflex exploring_stores {
		////////////////////////////////////////////////////////////////////////////////
		Store temp_store;
		//using global list to check if passed to nearby store
		loop i from:1 to: length(AllStores){
			temp_store<-AllStores[i-1];
			if (self.location distance_to temp_store.location)<(distanceThreshould*3){
//				write(temp_store.storeName + " is at " + int(last_index_of(visited_stores,temp_store)));
				if last_index_of(visited_stores,temp_store)!=length(visited_stores)-1{
					write("adding "+ temp_store.storeName +" to memory");
					do add_to_list (temp_store);}
			}
		}
		/////////////////////////////////////////////////////////////////////////////////
 
	}
	reflex move_Random when:(is_hungry>0 and is_thursty>0){
//		float speed <- 20.0;
		do wander speed:10.0;
		current_loc<-self.location;
		if temp_dist!=total_dist{
			write("current_total_dist="+total_dist);
			temp_dist<-total_dist;
			hungry_thirsty_time_count<-hungry_thirsty_time_count+1;
			write( string(hungry_thirsty_time_count) +" time got hungry/thirsty");
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
				write(TargetStore);
				write("at centre");
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
		storeName <- "Store Numero " + (num-1);
	}
 	Store report_nearby{
 		return self;
 	}
	bool sellDrink{
		if(drinkSupplies > 0){
			drinkSupplies <- drinkSupplies -1;
			write(storeName + " sold drink");
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
	Store giveInfo (Person p) {
 
        Store foundStore <- nil; // Apparently we cant return inside the ask so we use this as a temp variable
		list<Store> matchingStores <- [];
 
        if (p.is_hungry =0 and p.is_thursty =0) {
        	write("dying");
            ask Store {
 
            	
	                if (self.hasFood and self.hasDrink) {
	                	//write(self);
	                	matchingStores[0] +<- self;
	                	//foundStore <- self;
	                	//break;
	                }
 
                
            }
        }
        else if (p.is_hungry=0) {
            ask Store{
            	write("burger!");
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
//	            if (! (p.visited_stores contains(self))){
	                if (self.hasDrink) {
	                	//write(self);
	                	//foundStore <- self;
	                	matchingStores[0] +<- self;
	 
	                	//break;
	                }
//	 			}
                
            }
        }
        if (matchingStores != []) {
    		foundStore <- one_of(matchingStores); // Selects a random store from the list
    		write("found_store"+foundStore);
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
		}
	}
}