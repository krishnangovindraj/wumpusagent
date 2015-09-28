% Run using test_agent("random_worlds.pl",Score, Time).

init_agent:- % Populates our knowledge base with basic information ( location, orientation, arrowcount ).
	writeln(init),
	restart_agent. % Dummy

restart_agent:- % Clears our knowledgeBase.
	writeln(reset).


% Dummy agent who just climbs
simple_problem_solving_agent(Percepts, climb):-	
	writeln(taking_action).


record_percept([Stench,Breeze,Glitter,Bump,Scream],[X,Y],Orientation):-	% Takes the percept, adds to the knowledgebase
	check_stench(Stench,[X,Y]),
	check_breeze(Breeze,[X,Y]),
	check_glitter(Glitter,[X,Y]),
	check_bump(Bump,[X,Y],Orientation),
	writeln(update_state).

update_state([X,Y],Orientation,Action):-
	Action=goforward, get_block_orientation([X,Y],Orientation,[X1,Y1]),asserta(cur_loc([X1,Y1])),asserta(cur_orient(Orientation));
	Action=turnleft,left(Orientation,Orient2),asserta(cur_orient(Orient2));
	Action=turnright,right(Orientation,Orient2),asserta(cur_orient(Orient2));
	Action=grab,asserta(got_gold([X,Y]));
	Action=shoot,assert(no_arrows);
	Action=climb.

search(Problem, Action):-	% Returns the action to take. 
	writeln(search).

formulate_goal(Goal):-		% Sets the goal. Goal E {explore, gohome} ( WE DONT NEED THIS )
	writeln(formulate_goal).


% Facts used
%	* no_pit([X,Y]).
% 	* no_wumpus([X,Y]).
%	* visited([X,Y]):- Tells you if [X,Y] has been visited.
%	* current_location([X,Y]):- Gives you the current location
%	* current_orientation(Angle):- Gives you your current orientation
%	* predecessor([X,Y]):- Returns [X',Y'] which is the square you were at before exploring [X,Y]
%       * wumpus_dead(TrueOrFalse).
 

% Inference rules:
%	OK([X,Y]) :- no_pit([X,Y]),no_wumpus([X,Y]).Tells you if [X,Y] is safe.
%	aiming_at_wumpus(Location,Orientation):- True if youre facing the wumpus
%	decide_action(Percept,Location,Orientation,Action):-
%		decides the action. Multiple clauses which determine what to do.
%       faceorgo(LocationStart, LocationFinal, Orientation, Action):- if facing the location, returns goforward; Else, rotate whichever way to face
%       record_percept(Action):-		% Records the percepts / inferences from the percepts.


% Search Strategy:
%       1. glitter -> grab
%       2. aiming_at_wumpus -> shoot
%       3. OK(North) && not visited(North) ->faceorgo(North)
%       4. OK(East) && not visited(East) ->faceorgo(East)
%       5. OK(South) && not visited(South) ->faceorgo(South)
%       6. OK(West) && not visited(West) ->faceorgo(West)
%		7. at(1,1) -> climb % Because if we reach here, then we ve explored everything.
%       8. faceorgo(predecessor(current_location))). % Backtrack!


%%%%%%%%%%%%%%
% Actions
%%%%%%%%%%%%%%

	decide_action([_,_,yes,_,_],[X,Y],_,grab).

	decide_action([yes,_,_,_,_],[X,Y],Orientation,shoot):-
		aiming_at_wumpus([X,Y],Orientation).

	decide_action(_,[X,Y],Orientation,Action):-
		OK(north([X,Y])),not visited(north([X,Y])),faceorgo([X,Y],Orientation,north([X,Y]),Action).
	
	decide_action(_,[X,Y],Orientation,Action):-
		OK(east([X,Y])),not visited(east([X,Y])),faceorgo([X,Y],Orientation,east([X,Y]),Action).

	decide_action(_,[X,Y],Orientation,Action):-
		OK(south([X,Y])),not visited(south([X,Y])),faceorgo([X,Y],Orientation,south([X,Y]),Action).
	
	
	decide_action(_,[X,Y],Orientation,Action):-
		OK(west([X,Y])),not visited(west([X,Y])),faceorgo(west([X,Y]),Action).
	
	% If execution reaches here, Then both [2,1], [1,2] are updated. Nothing to do but climb
	decide_action(_,[1,1],_,climb).
	
	% Nothing to do. Go back
	decide_action(_,[X,Y],Orientation,Action):-
		faceorgo([X,Y],Orientation,predecessor([X,Y]),Action).
	

	faceorgo([X,Y], Orientation, [X1,Y1], goforward):-
		get_orientation_block([X,Y],Orientation,[X2,Y2]),		
		[X1,Y1] = [X2,Y2].
	

	faceorgo([X,Y], Orientation, [X1,Y1], turnleft):-
		get_orientation_block([X,Y],left(Orientation),[X2,Y2]),		
		[X1,Y1] = [X2,Y2].
	
	faceorgo([X,Y], Orientation, [X1,Y1], turnright).



% Inferences:
% TO DO
%	aiming_at_wumpus


	ok([X,Y]):-
		no_pit([X,Y]),
		no_wumpus([X,Y]).


%
% Utility functions related to motion
%
	north([X,Y],[X1,Y1]):-
		X1 is X,Y1 is Y+1.

	south([X,Y],[X1,Y1]):-
		X1 is X,Y1 is Y-1.

	east([X,Y],[X1,Y1]):-
		X1 is X+1,Y1 is Y.

	west([X,Y],[X1,Y1]):-
		X1 is X-1,Y1 is Y.

	left(eastd,northd).
	left(northd,westd).
	left(westd,southd).
	left(southd,eastd).

	right(eastd,southd).
	right(southd,westd).
	right(westd,northd).
	right(northd,eastd).


	get_block_orientation([X,Y], northd,[X1,Y1]):- north([X,Y],[X1,Y1]).
	get_block_orientation([X,Y], eastd, [X1,Y1]):- east([X,Y], [X1,Y1]).
	get_block_orientation([X,Y], southd,[X1,Y1]):- south([X,Y],[X1,Y1]).
	get_block_orientation([X,Y], westd, [X1,Y1]):- west([X,Y], [X1,Y1]).

%%%%%%%%%%%%%%%%%%%%%
% Percept analysis %
%%%%%%%%%%%%%%%%%%%%
	check_stench(no,[X,Y]):-
		north([X,Y],[X1,Y1]),
		assert(no_wumpus([X1,Y1])),
		south([X,Y],[X2,Y2]),
		assert(no_wumpus([X2,Y2])),
		east([X,Y],[X3,Y3]),
		assert(no_wumpus([X3,Y3])),
		west([X,Y],[X4,Y4]),
		assert(no_wumpus([X4,Y4])).

	check_stench(yes,[X,Y]).

	check_breeze(no,[X,Y]):-
		north([X,Y],[X1,Y1]),
		assert(no_pit([X1,Y1])),
		south([X,Y],[X2,Y2]),
		assert(no_pit([X2,Y2])),
		east([X,Y],[X3,Y3]),
		assert(no_pit([X3,Y3])),
		west([X,Y],[X4,Y4]),
		assert(no_pit([X4,Y4])).

	check_breeze(yes,[X,Y]).

	check_glitter(yes,[X,Y]):-
		assert(got_gold([X,Y])).

	check_glitter(no, [X,Y]).

	check_bump(yes,[X,Y], Orientation):-
		get_block_orientation([X,Y],Orientation,[X1,Y1]),
		assert(out_of_bound([X1,Y1])).

	check_bump(no,[X,Y], Orientation).

