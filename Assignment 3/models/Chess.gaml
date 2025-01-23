/**
* Name: NewModel
* Based on the internal empty template. 
* Author: kjk54
* Tags: 
*/


model Chess

global {
	int numberOfQueen <- 5;
	int starting_queen<-0;// between 0 and numberOfQueen-1
	int curr_i<-coord_o;
	int curr_j<-coord_o;
	matrix board<-matrix_with(point(numberOfQueen), nil);
	matrix chesses<-matrix_with(point(numberOfQueen),nil);
	int cell_size<-5;
	int coord_o<-10;
	list allQueen<-list_with(numberOfQueen,nil);
	
	bool succeed<-false;
	//Centre InfoCentre;
//	Store targetstore;
	init {
		
		create Queen number: numberOfQueen;
 		create Chessboard number:1;
		loop counter from:0 to: numberOfQueen-1 {
			loop j from:0 to: numberOfQueen-1{
//				write("counter,j"+counter+";"+j);
				board[counter,j]<-point(curr_i,curr_j);
				curr_j<-curr_j+cell_size;
			}
//			write(board);
//			write("ok");
			curr_i<-curr_i+cell_size;
			curr_j<-coord_o;
		}
		loop counter from:0 to: numberOfQueen-1{
			Queen temp_q<-Queen[counter];
			allQueen[counter]<-temp_q;
			temp_q <- temp_q.setQueenName(counter);
		}
	}
}
species Chessboard skills:[fipa]{

	bool begin_m<-true;
	reflex begin when: begin_m=true{
		bool skip<-false;
		begin_m<-false;
		do start_conversation to:allQueen[starting_queen] protocol:'no-protocol' performative:'inform' contents:["continue"];
		write("begin conversation");
	}
	reflex check_pose when: !empty(informs){
//		bool continue<-true;
		message informMsg<-informs[0];
		if "moved" in string(informMsg.contents[0]){
			bool correct;
			correct<- check_correct();
			write("correct? "+correct);
			if correct=false{
				do inform message:informMsg contents:["continue",numberOfQueen-1];
			}
			else{
				write("succeed finally");
				do end_conversation message:informMsg contents:['end!'];
				succeed<-true;
			}
		}
	}
			
	bool check_correct{
		bool value<-false;
			loop x from: 0 to: numberOfQueen-1{
				int oneIncol<-0;
				loop y from: 0 to: numberOfQueen-1{
	//				write(string(chesses[x,y]));
					if chesses[x,y]=true{
						oneIncol<-oneIncol+1;
					}
					if oneIncol>1{
						return value;
					}
	//					
				}
			}
//			value<-true;
			
			loop i from:0 to: numberOfQueen-1{
				Queen queen<-allQueen[i];
				int co_x<-queen.co_x;
				int co_y<-queen.co_y;
				
					list left<-[[co_x-1,co_y-1],[co_x-1,co_y+1]];
					list rait<-[[co_x+1,co_y-1],[co_x+1,co_y+1]];
					if co_y=0{
						left<-[[co_x-1,co_y+1]];//[x-1,numberOfQueen-1],
						rait<-[[co_x+1,co_y+1]];//[x+1,numberOfQueen-1],
					}
					else if co_y=numberOfQueen-1{
						left<-[[co_x-1,co_y-1]];//,[x-1,0]
						rait<-[[co_x+1,co_y-1]];//,[x+1,0]
					}
					list total<-left+rait;
					
					if co_x!=0 and co_x!=numberOfQueen-1{
						loop n over: total{
	//						write(QueenName+" total "+total);
							if chesses[point(n)]=true{return value;}
						}
					}
					else if co_x=0{
	//					write("ok");
						loop n over: rait{
							
							if chesses[point(n)]=true{return value;}	
						}
					}	
					else if co_x=numberOfQueen-1{
						loop n over: left{
							if chesses[point(n)]=true{return value;}
						}
					}
				}
				value<-true;
				return value;
	}
		
	aspect base{
		rgb col<-rgb("white");
		rgb cell<-rgb("black");
		bool cl<-false;
		bool is_even<-false;
		if (numberOfQueen mod 2)=0{
			is_even<-true;//偶数
		}
		loop i from:0 to: numberOfQueen-1{
			if is_even and cl=false{
				cl<-true;
			}
			else if is_even and cl=true{
				cl<-false;
			}
			loop j from:0 to: numberOfQueen-1{
				if cl=false{
					col<-rgb("black");
					cl<-true;
				}
				else{
					col<-rgb("white");
					cl<-false;
				}
				draw square(cell_size) color:col border:cell at: point(board[i,j]);
				}
		}
	}
}

species Queen skills:[moving,fipa]{
//	int is_hungry  <- int(rnd(5,10));
	string QueenName<-nil;
	int co_x<-0;
	int co_y<-0;
	bool begin_m<-true;
	action setQueenName(int num){
		QueenName<-"Queen "+string(num);
		co_y<-num;//co_x=0,即所有棋都在(0,co_y)坐标
		chesses[co_x,co_y]<-true;
//		write(string(chesses[co_x,co_y]));
	}
//	reflex set_off when: begin_m=true and co_y=numberOfQueen-1{// 
//		begin_m<-false;
//		do start_conversation to:list(Queen) protocol:'no-protocol' performative:'inform' contents:["ok"+co_y];
//		write("begin conversation "+QueenName);
//	}
	reflex receive_informs when: !empty(informs) and succeed=false{//and processing=false
//		write(QueenName+"received");
		
		message informMsg<-informs[0];
		string content<-string(informMsg.contents[0]);
//		int target<-int(informMsg.contents[1]);
		
		if ("continue" in content) or (("upper" in content) and (string(co_y) in content)){
//			write(QueenName+" received");
			int i<-0;
			write(QueenName+" at "+co_x);
			if co_x=numberOfQueen-1{
//				write(QueenName+" informed: upper one!"+(co_y-1));
				int target<-0;
				if co_y!=0{
					target<-co_y-1;
				}
				else{
					target<-numberOfQueen-1;
				}
				do start_conversation to:list(Queen) protocol:'no-protocol' performative:'inform' contents:["upper one!"+target];
//				do inform message:informMsg contents:["upper one!"+(co_y-1)];
			}
			else{
				i<-co_x+1;
			}
			do goto target:point(board[i,co_y]);
			chesses[co_x,co_y]<-false;
			chesses[i,co_y]<-true;
//			write(QueenName+": move from "+ (co_x)+" to "+(i));	
			co_x<-i;
			if ("upper" in content){
//				do end_conversation message:informMsg contents:['end!'];
			}
			do inform message:informMsg contents:["I_moved "];
			
			
	
		}
	
	}
//		if "upper one" in string(informMsg.contents[0]) and co_y!=numberOfQueen-1
	
	
	


	
	aspect base{
//		write("point"+point(board[co_x,co_y]));
		draw circle(cell_size/2.5) color:rgb("tan") border:rgb("gold") at: point(board[co_x,co_y]);
		
	}
}
 
experiment myExperiment type:gui{
	output{
		display myDisplay {
			species Chessboard aspect:base;
			species Queen aspect: base;
		}
	}
}
/* Insert your model definition here */
