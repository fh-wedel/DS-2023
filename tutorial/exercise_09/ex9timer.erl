% Exercise 9: Timers

-module(ex9timer).
-export([start/2, start/3]).


ticker(Speed, ClockPID) ->
    receive
    after
        Speed * 1000 -> ClockPID ! tick, ticker(Speed, ClockPID)
    end.

% paused
timer(Val, paused, Fun) ->
    io:format("paused: ~p~n", [Val]),
    receive
        {set, Value} -> timer(Value, paused, Fun);
        resume -> timer(Val, running, Fun);
        tick ->  timer(Val, paused, Fun);
        stop -> ok
    end;
% running
timer(0, running, Fun) ->
    Fun();
timer(Val, running, Fun) ->
    io:format("running: ~p~n", [Val]),
    receive
        {set, Value} -> timer(Value, running, Fun);
        pause -> timer(Val, paused, Fun);
        tick -> timer(Val - 1, running, Fun);
        stop -> ok
    end.

alert() ->
    io:format("Time elapsed!!!!!!!!~n").

start(Speed, Ticks) ->
    Timer = spawn(fun() -> timer(Ticks, running, fun() -> alert() end) end),
    spawn(fun() -> ticker(Speed, Timer) end),
    Timer.


start(Speed, Ticks, Fun) ->
    Timer = spawn(fun() -> timer(Ticks, running, Fun) end),
    spawn(fun() -> ticker(Speed, Timer) end),
    Timer.

%ex9timer:start(1,3, fun() -> io:format("Hallo Prof!~n") end ).