% Exercise 8: Filters and Pipelines in Erlang

-module(ex8).
-export([echo/0, start/0, start1/0, start2/0]).

echo() ->
   receive
   	   stop -> ok;
   	   Msg -> io:format("~p\n",[Msg]), echo()
   end.

filter(TargetPid, 0, ResetVal) ->
    receive
        {set_sender, NewTargetPid} -> filter(NewTargetPid, 0, ResetVal);
        {filter,Msg} -> TargetPid ! {filter,Msg}, filter(TargetPid, ResetVal, ResetVal)
    end;
filter(TargetPid, I, ResetVal) ->
    receive
        {set_sender, NewTargetPid} -> filter(NewTargetPid, I, ResetVal);
        {filter,_} -> filter(TargetPid, I-1, ResetVal)
    end.

filter(TargetPid, I) ->
    filter(TargetPid, I-1, I-1).

collector(TargetPid, List) ->
    receive
        {set_sender, NewTargetPid} -> collector(NewTargetPid, List);
        reset -> collector(TargetPid, []);
        {filter, Msg} -> TargetPid ! {filter, List ++ [Msg]}, collector(TargetPid, List ++ [Msg])
    end.

start1() ->
    Echo = spawn(?MODULE, echo,[]),

    Filter = spawn(fun() -> filter(Echo,2) end),
 
    P2 = Filter,
    
 
    P2!{filter,1},
    P2!{filter,2},
    P2!{filter,3},
    P2!{filter,4},
    P2!{filter,5},
    ok.

start2() ->
    Echo = spawn(?MODULE, echo,[]),
    Collector = spawn(fun() -> collector(Echo,[]) end),
 
    C = Collector,
    
    C!{reset},
    C!{filter,1},
    C!{filter,b},
    C!{filter,3},
    
    ok.



start() ->
    Echo = spawn(?MODULE, echo,[]),
    Collector = spawn(fun() -> collector(Echo,[]) end),
    Filter = spawn(fun() -> filter(Collector,2) end),
 
    P2 = Filter,
 
    P2!{filter,120},
    P2!{filter,109},
    P2!{filter,150},
    P2!{filter,101},
    P2!{filter,155},
    P2!{filter,114},
    P2!{filter,189},
    P2!{filter,114},
    P2!{filter,27},
    P2!{filter,121},
    P2!{filter,68},
    P2!{filter,32},
    P2!{filter,198},
    P2!{filter,99},
    P2!{filter,33},
    P2!{filter,104},
    P2!{filter,164},
    P2!{filter,114},
    P2!{filter,212},
    P2!{filter,105},
    P2!{filter,194},
    P2!{filter,115},
    P2!{filter,24},
    P2!{filter,116},
    P2!{filter,148},
    P2!{filter,109},
    P2!{filter,173},
    P2!{filter,97},
    P2!{filter,8},
    P2!{filter,115},
    P2!{filter,191},
    P2!{filter,33},

    ok.
