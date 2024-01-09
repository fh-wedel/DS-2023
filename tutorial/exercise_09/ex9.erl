% Exercise 9: Timers

-module(ex9).
-export([start_ra/1, get_ra/1, start/1, get/1, startEvilTicker/2]).


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
        Speed -> clock_ra(Speed, Val + 1, running)
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
        Speed -> ClockPID ! {tick, self()}, ticker(Speed, ClockPID)
    end.


clock(Val, undefined, init) ->
    receive
        {start_clock, TickerID} -> clock(Val, TickerID, running) 
    end;
% paused
clock(Val, TickerID, paused) ->
    receive
        {set, Value} -> clock(Value, TickerID, paused);
        {get, Pid} -> Pid ! {clock, Val}, clock(Val, TickerID, paused);
        resume -> clock(Val, TickerID, running);
        tick -> clock(Val, TickerID, paused);
        stop -> ok
    end;
% running
clock(Val, TickerID, running) ->
    receive
        {set, Value} -> clock(Value, TickerID, running);
        {get, Pid} -> Pid ! {clock, Val}, clock(Val, TickerID, running);
        pause -> clock( Val, TickerID, paused);
        {tick, Sender} when Sender == TickerID -> clock(Val + 1, TickerID, running);
        stop -> ok
    end.

start(Speed) ->
    Clock = spawn(fun() -> clock(0, undefined, init) end),
    Ticker = spawn(fun() -> ticker(Speed, Clock) end),
    Clock ! {start_clock, Ticker},
    Clock.

get(ClockID) -> 
    ClockID ! {get, self()},
    receive 
        {clock, Val} -> Val 
    end.

startEvilTicker(Speed, Clock) ->
    spawn(fun() -> ticker(Speed, Clock) end).