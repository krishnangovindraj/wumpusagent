% Run using test_agent("random_worlds.pl",Score, Time).
% test_agent("chickenworld.pl",Score, Time).


% Declare the predicates we'll be using in our knowledgebase
:- dynamic
	no_pit/1,
	no_wumpus/1,
	visited/1,
	out_of_bound/1,
	predecessor/2,
	action_sequence/1,
	cur_loc/1,
	cur_orient/1,
	no_arrows/0,
	got_gold/1,
	goal_achieved/1,
	agent_debug/1.


init_agent:- % Populates our knowledge base with basic information ( location, orientation, arrowcount ).
	restart_agent,
	asserta(action_sequence(climbdown)),
	assert_once(cur_loc([1,1])),
	assert_once(cur_orient(eastd)),
	assert_once(visited([1,1])),
	
	writeln(init).


restart_agent:- % Clears our knowledgeBase.
	retractall(no_arrows),
	retractall(got_gold(_)),
	retractall(visited(_)),
	retractall(no_wumpus(_)),
	retractall(no_pit(_)),
	retractall(out_of_bound(_)),
	retractall(predecessor(_,_)),
	retractall(action_sequence(_)),
	retractall(cur_loc(_)),
	retractall(cur_orient(_)),
	retractall(goal_achieved(_)),
	retractall(wumpus_dead),
	retractall(wumpus_possible(_)),
	writeln(reset).



% Agent code

simple_problem_solving_agent(Percepts, Action):-	action_sequence(PreviousAction),
	cur_loc(PreviousLocation), cur_orient(PreviousOrientation),
	update_state(Percepts, PreviousAction, PreviousLocation, PreviousOrientation),
	cur_loc(CurrentLocation), cur_orient(CurrentOrientation),
	record_percept(Percepts,CurrentLocation, CurrentOrientation),
	formulate_goal(Goal),
	search( Goal, Percepts, CurrentLocation, CurrentOrientation, Action),
	asserta(action_sequence(Action)),
	writeln(taking_action).

formulate_goal(preliminary_exploration):-
	not(goal_achieved(preliminary_exploration)).
	
formulate_goal( kill_wumpus ):-
	can_kill_wumpus, not(goal_achieved(kill_wumpus)),not(no_arrows).
	

formulate_goal( secondary_exploration ):-
	OK([X,Y]) , not(visited([X,Y])).

formulate_goal( go_home ).


search( preliminary_exploration, Percepts, CurrentLocation, CurrentOrientation, Action ):-
	decide_action(Percepts, CurrentLocation, CurrentOrientation, Action).

search( go_home, Percepts, CurrentLocation, CurrentOrientation, Action ):-
	find_way_home( CurrentLocation, CurrentOrientation, Action ).

search( Goal, Percepts, CurrentLocation, CurrentOrientation, Action ):-
	search( go_home, Percepts, CurrentLocation, CurrentOrientation, Action ).	

record_percept([Stench,Breeze,Glitter,Bump,Scream],[X,Y],Orientation):-	% Takes the percept, adds to the knowledgebase
	check_stench(Stench,[X,Y]),
	check_breeze(Breeze,[X,Y]),
	check_glitter(Glitter,[X,Y]),
	check_bump(Bump,[X,Y],Orientation),
	writeln(record_percept).

update_state([_,_,_,Bump,_],Action,[X,Y],Orientation):- % Take care of the bump
	Action=goforward, Bump=yes,	get_block_orientation([X,Y],Orientation,[X1,Y1]),assert_once(visited([X1,Y1])),assert_once(out_of_bound([X1,Y1])),writeln([outofbounds,X1,Y1]);

	Action=goforward, 
		Bump=no,
		get_block_orientation([X,Y],Orientation,[X1,Y1]),
		asserta(cur_loc([X1,Y1])),asserta(cur_orient(Orientation)),
		assert_once(visited([X1,Y1])),
		assert_once(predecessor([X1,Y1],[X,Y]));

	Action=turnleft,left(Orientation,Orient2),asserta(cur_orient(Orient2));
	Action=turnright,right(Orientation,Orient2),asserta(cur_orient(Orient2));
	Action=grab,asserta(got_gold([X,Y]));
	Action=shoot,assert_once(no_arrows);
	Action=climb;
	Action=climbdown.


% Facts used
%	* no_pit([X,Y]).
%	* no_wumpus([X,Y]).
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

	%%%%%%%%%%%%%%%%%%%%%%%%%
	% preliminary_exploration
		%%%%%%%%%%%%%%%%%%%%%%%%%
		decide_action( [_,_,yes,_,_],[X,Y],_,grab):-
			writeln(grab).

		decide_action( [yes,_,_,_,_],[X,Y],Orientation,shoot):-
			aiming_at_wumpus([X,Y],Orientation),
			writeln(shoot).

		decide_action( _,[X,Y],Orientation,Action):-
			north([X,Y],[X1,Y1]),
			ok([X1,Y1]),not(visited([X1,Y1])),
			faceorgo([X,Y],Orientation,[X1,Y1],Action),
			writeln(gonorth).

		decide_action( _,[X,Y],Orientation,Action):-
			east([X,Y],[X1,Y1]),
			ok([X1,Y1]),not(visited([X1,Y1])),
			faceorgo([X,Y],Orientation,[X1,Y1],Action),
			writeln(goeast).

		decide_action( _,[X,Y],Orientation,Action):-
			south([X,Y],[X1,Y1]),
			ok([X1,Y1]),not(visited([X1,Y1])),
			faceorgo( [X,Y], Orientation, [X1,Y1], Action ),
			writeln(gosouth).

		decide_action( _,[X,Y],Orientation,Action):-
			west([X,Y],[X1,Y1]),
			ok([X1,Y1]),not(visited([X1,Y1])),
			faceorgo([X,Y],Orientation,[X1,Y1],Action),
			writeln(gowest).

		% If execution reaches here, Then both [2,1], [1,2] are explored completely. Preliminary exploration is complete
		decide_action( _,[1,1],_,Action):-	% Grab does nothing
			assert_once(goal_achieved(preliminary_exploration)),
			formulate_goal(Goal),
			search( Goal, Percepts, CurrentLocation, CurrentOrientation, Action).	% Fail so that we're forced to search for another goal

		% Nothing to do here. Go back

		decide_action( _,[X,Y],Orientation,Action):-
			predecessor([X,Y],[PX1,PY1]),
			faceorgo([X,Y],Orientation,[PX1,PY1],Action).

	%%%%%%%%%%%%%%%%%%%%%%
	%% go_home 
	%%%%%%%%%%%%%%%%%%%%%%
		find_way_home( [1,1], CurrentOrientation, climb ).
		
		find_way_home( CurrentLocation, CurrentOrientation, Action ):-
			predecessor([X,Y],[PX1,PY1]),
			faceorgo([X,Y],Orientation,[PX1,PY1],Action).
	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	INFERENCES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	ok([X,Y]):-
		% not(out_of_bound([X,Y])),
        no_pit([X,Y]),
		no_wumpus([X,Y]).

	can_kill_wumpus:-
		where_is_wumpus( PossibleLocations ),
		assert_once( agent_debug(PossibleLocations) ).
		
		
				
	where_is_wumpus( PossibleLocations ):-
		collect_facts([], PossiblityList),
		set_intersection(PossiblityList, IntersectionResult),
		eliminate_no_wumpus_blocks( IntersectionResult, PossibleLocations),
		update_no_wumpus(PossibilityList, PossibleLocations).

	eliminate_no_wumpus_blocks( [], []).
	eliminate_no_wumpus_blocks( [H|T], PossibleLocations):-  % If the block is safe, don't add it
		no_wumpus( H ),
		eliminate_no_wumpus_blocks(T, PossibleLocations).
		
	eliminate_no_wumpus_blocks( [H|T], [H|PossibleLocations]):- %Else, add it to the possible locations
		eliminate_no_wumpus_blocks(T, PossibleLocations).
		
	
	update_no_wumpus( PossiblitiesNow, ThoseToKeep). % TO DO
		
		collect_facts(ExistingList, ResultList):-	% Collects all the facts and returns a list
			wumpus_possible(NewItem),
			not(member(NewItem,ExistingList)),
			collect_facts([NewItem|ExistingList], ResultList).
		
		collect_facts(FinalList, FinalList).	%Base case
		
		
	aiming_at_wumpus([X,Y],Orientation):-
		false.
		
		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utility functions related to motion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	faceorgo([X,Y], Orientation, [X1,Y1], goforward):-
		get_block_orientation([X,Y],Orientation,[X1,Y1]),
		writeln(goforward).


	faceorgo([X,Y], Orientation, [X1,Y1], turnleft):-
		left(Orientation, LeftOfOrientation),
		get_block_orientation([X,Y],LeftOfOrientation,[X1,Y1]),
		writeln(turnleft).

        faceorgo([X,Y], Orientation, [X1,Y1], turnright):-
		writeln(turnright).

	
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
		assert_once(no_wumpus([X1,Y1])),
		south([X,Y],[X2,Y2]),
		assert_once(no_wumpus([X2,Y2])),
		east([X,Y],[X3,Y3]),
		assert_once(no_wumpus([X3,Y3])),
		west([X,Y],[X4,Y4]),
		assert_once(no_wumpus([X4,Y4])).
	
	check_stench(yes,[X,Y]):-
		north([X,Y],[X1,Y1]),
		south([X,Y],[X2,Y2]),
		east([X,Y],[X3,Y3]),
		west([X,Y],[X4,Y4]),
		assert_once(wumpus_possible( [ [X1,Y1], [X2,Y2], [X3,Y3], [X4,Y4] ] )).
		

	check_breeze(no,[X,Y]):-
		north([X,Y],[X1,Y1]),
		assert_once(no_pit([X1,Y1])),
		south([X,Y],[X2,Y2]),
		assert_once(no_pit([X2,Y2])),
		east([X,Y],[X3,Y3]),
		assert_once(no_pit([X3,Y3])),
		west([X,Y],[X4,Y4]),
		assert_once(no_pit([X4,Y4])).

	check_breeze(yes,[X,Y]).

	check_glitter(yes,[X,Y]):-
		assert_once(got_gold([X,Y])).

	check_glitter(no, [X,Y]).

	check_bump(yes,[X,Y], Orientation):-
		get_block_orientation([X,Y],Orientation,[X1,Y1]),
		assert_once(out_of_bound([X1,Y1])).

	check_bump(no,[X,Y], Orientation).


%%%%%%%%%%%%%%%%%%%%%%%%
% Set operations
%%%%%%%%%%%%%%%%%%%%%%%%
	%Not already a member
	add_to_set( [H|T], ListSoFar, ResultList):-
		not(member(H, ListSoFar)),
		add_to_set( T, [H|ListSoFar], ResultList).

	add_to_set( [], FinalList, FinalList).

	set_intersection( ListOfLists, ResultList):-
		[H|T] = ListOfLists,
		add_to_set( H, [], HeadSet),
		set_intersection( T, HeadSet, ResultList).

	set_intersection( [Head|Tail], ListSoFar, ResultList):-
		do_intersect(Head, ListSoFar, TempResult),
		set_intersection(Tail, TempResult, ResultList).

	set_intersection([], FinalList, FinalList).
	
	do_intersect(_, [], []).

	do_intersect(Addition, [H|T], ResultList):- % Is member
		member(H, Addition),
		do_intersect(Addition, T, TempResult),
		ResultList =  [H|TempResult].

	do_intersect(Addition, [H|T], ResultList):- % Is not member
		not(member(H,Addition)),
		do_intersect( Addition, T, ResultList).



% Reusing assert over and over again introduces duplicate facts in our KB. They're rechecked during search.
% assert_once only adds if the fact isn't yet in our KB
assert_once(SomeFact):-
	SomeFact.

assert_once(SomeFact):-
	assert(SomeFact).
