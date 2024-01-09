-module(ex10).
-import(ex9, [start/1]).
-export([server/0,client/0]).

server(Clock) ->
    % Clock = spawn() awdawda
    receive
        {get, Pid} -> %awdawda , server() 
    end
    ok.

client() ->
    ok.

startServer() ->
    ServerClock = spawn(fun() -> ) 