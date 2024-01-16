-module(ex11).
-import(lists, [append/2, member/2]).
-compile(export_all).


counter(ElectionCnt) -> 
    receive
        election -> counter(ElectionCnt + 1);
        getCount -> io:format("~p election messages total ~n", [ElectionCnt]), counter(ElectionCnt)
    end.

rpc(Pid, Request, C) -> 
    Pid ! {self(), Request}, C ! Request,
    receive 
       {Pid, Response} -> 
           Response
    after 250 -> 
        unreachable
    end.


sendElection(Pid, [H|T], Group, C) ->
    if 
        Pid > H -> sendElection(Pid, T, Group, C);
        true -> io:format("~p: sending election message to: ~p ~n", [Pid, H]),
                case rpc(H, election, C) of
                    ok -> io:format("~p: got ok from: ~p ~n", [Pid, H]), ok;
                    unreachable -> io:format("~p: got unreachable from: ~p ~n", [Pid, H]), sendElection(Pid, T, Group, C)
                end
    end;
sendElection(Pid, [], Group, _) ->
    sendCoordinator(Pid, Group), 
    unreachable.


sendCoordinator(Pid, [H|T]) ->
    io:format("~p: sending coordinator message to: ~p ~n", [Pid, H]),
    H ! {coordinator, Pid}, sendCoordinator(Pid, T);
sendCoordinator(Pid, []) ->
    io:format("~p: all coordinator messages sent. ~n", [Pid]).
    

addToGroup(Pid, Group) ->
    IsMem = member(Pid, Group),
    if
        IsMem -> Group;
        true -> append(Group, [Pid])
    end.

% The state of each process contains at least the current coordinator (maybe the own election
% value) and also a list of all other processes in the group.
process(undefined, Group, C) ->
    case sendElection(self(), Group, Group, C) of 
        unreachable -> process(self(), Group, C);
        ok ->
            receive
                {coordinator, Pid} -> process(Pid, Group, C)
            end
    end;
process(Coordinator, Group, C) ->
    receive
        startElection -> sendElection(self(), Group, Group, C), process(Coordinator, Group, C);
        {Pid, election} -> Pid ! {self(), ok}, sendElection(self(), Group, Group, C), process(Coordinator, addToGroup(Pid, Group), C);
        {coordinator, Pid} -> process(Pid, addToGroup(Pid, Group), C);
        stop -> ok
    end.


setupCounter() -> 
    spawn(fun() -> counter(0) end).

setup(Counter) ->
    P1 = spawn(fun() -> process(undefined, [], Counter) end),
    P2 = spawn(fun() -> process(undefined, [P1], Counter) end),
    P3 = spawn(fun() -> process(undefined, [P1,P2], Counter) end),
    P4 = spawn(fun() -> process(undefined, [P1,P2,P3], Counter) end),
    P5 = spawn(fun() -> process(undefined, [P1,P2,P3,P4], Counter) end),
    [P1,P2,P3,P4,P5].

startOne(Group, Counter) ->
    spawn(fun() -> process(undefined, Group, Counter) end).

stopSome(Group) ->
    lists:nth(5, Group) ! stop, 
    lists:nth(2, Group) ! stop.

startElection(Pid) ->
    Pid ! startElection.

%C = ex11:setupCounter().
%G = ex11:setup(C).
%ex11:startElection(lists:nth(1,G)).