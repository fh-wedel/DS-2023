% Exercise 9: Timers

-module(ex9).
-export([start_ra/1,get_ra/1,start/1,get/1]).


% a)

% paused
clock_ra(Speed, Val, paused) ->
    receive
        {set, Value} -> clock_ra(Speed, Value, paused);
        {get, Pid} -> Pid ! {clock, Val}, clock_ra(Speed, Val, paused);
        resume -> clock_ra(Speed, Val, running);
        stop -> ok
    end;
% running
clock_ra(Speed, Val, running) ->
    receive
        {set, Value} -> clock_ra(Speed, Value, running);
        {get, Pid} -> Pid ! {clock, Val}, clock_ra(Speed, Val, running);
        pause -> clock_ra(Speed, Val, paused);
        stop -> ok
    after 
        Speed * 1000 -> clock_ra(Speed, Val + 1, running)
    end.

% b)
start_ra(Speed) ->
    spawn(fun() -> clock_ra(Speed, 0, running) end).


% c)
get_ra(ClockID) -> 
    ClockID ! {get, self()},
    receive 
        {clock, Val} -> Val 
    end.

% ----------------------------------------------------------------------

% d)
% Using receive ... after directly in the clock process has a serious drawback. Can you spot what it is?
% -> The Timer 'resets' after receiving a (get) Message.

ticker(Speed, ClockPID) ->
    receive
    after
        Speed * 1000 -> ClockPID ! tick, ticker(Speed, ClockPID)
    end.

% paused
clock(Val, paused) ->
    receive
        {set, Value} -> clock(Value, paused);
        {get, Pid} -> Pid ! {clock, Val}, clock(Val, paused);
        resume -> clock(Val, running);
        stop -> ok
    end;
% running
clock(Val, running) ->
    receive
        {set, Value} -> clock(Value, running);
        {get, Pid} -> Pid ! {clock, Val}, clock(Val, running);
        pause -> clock( Val, paused);
        tick -> clock(Val + 1, running);
        stop -> ok
    end.

start(Speed) ->
    Clock = spawn(fun() -> clock(0, running) end),
    spawn(fun() -> ticker(Speed, Clock) end),
    Clock.

get(ClockID) -> 
    ClockID ! {get, self()},
    receive 
        {clock, Val} -> Val 
    end.
