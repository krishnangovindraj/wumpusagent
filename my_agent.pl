% Run using test_agent("random_worlds.pl",Score, Time).

init_agent:- % Populates our knowledge base with basic information ( location, orientation, arrowcount ).
	writeln(init),
	reset_agent. % Dummy

reset_agent:- % Clears our knowledgeBase.
	writeln(reset).


% Dummy agent who just climbs
simple_problem_solving_agent(Percepts, Action):-	
	writeln(taking_action).


update_state(Percept):-		% Takes the percept, adds to the knowledgebase
	writeln(update_state).

search(Problem, Action):-	% Returns the action to take. 
	writeln(search).

formulate_goal(Goal):-		% Sets the goal. Goal E {explore, gohome} ( WE DONT NEED THIS )
	writeln(formulate_goal).

record_action(action):-		% Records whatever change occurs as a result of the action.
	writeln(record_action).


% Facts used
%	* no_pit([X,Y]).
% 	* no_wumpus([X,Y]).
%	* visited([X,Y]):- Tells you if [X,Y] has been visited.
%	* current_location([X,Y]):- Gives you the current location
%	* current_orientation(Angle):- Gives you your current orientation
%	* predecessor([X,Y]):- Returns [X',Y'] which is the square you were at before exploring [X,Y]
%       * wumpus_dead(TrueOrFalse).

% Inference rules:
%	OK([X,Y]) :- Tells you if [X,Y] is safe.
%	aiming_at_wumpus(Location,Orientation):- Tells if youre facing the wumpus
%	decide_action(Percept,Location,Orientation,Action):-	decides the action. Multiple clauses which determine what to do.
%       faceorgo(Location, Action):- if facing the location, returns goforward; Else, rotate whichever way to face
%       record_action(Action):-		% Records whatever change occurs as a result of the action.

% Search Strategy:
%       1. glitter -> grab
%       2. aiming_at_wumpus -> shoot
%       3. OK(North) && not visited(North) ->faceorgo(North)
%       4. OK(East) && not visited(East) ->faceorgo(East)
%       5. OK(South) && not visited(South) ->faceorgo(South)
%       6. OK(West) && not visited(West) ->faceorgo(West)
%       7. faceorgo(predecessor(current_location))). % Backtrack!



