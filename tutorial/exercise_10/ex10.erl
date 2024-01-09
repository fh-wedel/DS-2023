-module(ex10).
-import(ex9, [start/1]).
-export([startServer/1, startClient/2, simulate/0, monitor/4, simulateAdj/0]).



getClockVal(ClockID) -> 
    ClockID ! {get, self()},
    receive 
        {clock, Val} -> Val 
    end.

server(Clock) ->
    receive
        {get, Pid} -> 
            T2 = getClockVal(Clock),
            {_, CUTC, _} = erlang:timestamp(),
            T3 = getClockVal(Clock),
            Pid ! {T2, CUTC, T3 },
            server(Clock);
        show -> 
            io:format("Server Time: ~p~n", [getClockVal(Clock)]), 
            server(Clock);
        stop -> Clock ! stop, ok
    end.

askTimeServer(Server) ->
    Server ! {get, self()},
    receive
        {T1, CUTC, T2} -> {T1, CUTC, T2}
    end.

client(Clock, Server) ->
    receive
        adjust -> 
            T1 = getClockVal(Clock),
            {T2, CUTC, T3} = askTimeServer(Server),
            T4 = getClockVal(Clock),
            TSync = CUTC + (((T2-T1)+(T4-T3))/2),
            Clock ! {set, TSync},
            client(Clock, Server);
        show -> 
            io:format("Client Time: ~p~n", [getClockVal(Clock)]), 
            client(Clock, Server);
        stop -> Clock ! stop, ok
    end.

setUpClock(Speed) ->
    Clock = start(Speed),
    {_, Secs, _} = erlang:timestamp(),
    Clock ! {set, Secs},
    Clock.

startClient(Speed, Server) ->
    Client = spawn(fun() -> client(setUpClock(Speed), Server) end),
    Client.

startServer(Speed) ->
    Server = spawn(fun() -> server(setUpClock(Speed)) end),
    Server.


monitor(S,C1,C2,C3) ->
    S ! show,
    C1 ! show,
    C2 ! show,
    C3 ! show,
    io:format("-----------------------------------------~n"). 

simulate() ->
    S = startServer(1000),
    C1 = startClient(1100, S),
    C2 = startClient(980, S),
    C3 = startClient(1300, S),
    {S,C1,C2,C3}.

adjClient(Clock, Server) ->
    receive
        adjust -> 
            T1 = getClockVal(Clock),
            {T2, CUTC, T3} = askTimeServer(Server),
            T4 = getClockVal(Clock),
            TSync = CUTC + (((T2-T1)+(T4-T3))/2),
            Clock ! {set, TSync},
            adjClient(Clock, Server);
        show -> 
            io:format("Client Time: ~p~n", [getClockVal(Clock)]), 
            adjClient(Clock, Server);
        stop -> Clock ! stop, ok
    after 3000 -> 
        T1 = getClockVal(Clock),
        {T2, CUTC, T3} = askTimeServer(Server),
        T4 = getClockVal(Clock),
        TSync = CUTC + (((T2-T1)+(T4-T3))/2),
        Clock ! {set, TSync},
        adjClient(Clock, Server)
    end.

startClientAdj(Speed, Server) ->
    Client = spawn(fun() -> adjClient(setUpClock(Speed), Server) end),
    Client.

simulateAdj() ->
    S = startServer(1000),
    C1 = startClientAdj(1100, S),
    C2 = startClientAdj(980, S),
    C3 = startClientAdj(1300, S),
    {S,C1,C2,C3}.
