-module(ex11).
-import(lists, [append/2, member/2]).
-compile(export_all).

rpc(Pid, Request) -> 
    Pid ! {self(), Request}, 
    receive 
       {Pid, Response} -> 
           Response
    after 250 -> 
        unreachable
    end.


sendElection(Pid, [H|T], Group) ->
    if 
        self() > H -> sendElection(Pid, T, Group);
        true -> case rpc(H, election) of
                    ok -> ok;
                    unreachable -> sendElection(Pid, T, Group)
                end
    end;
sendElection(Pid, [], Group) ->
    sendCoordinator(Pid, Group), 
    unreachable.


sendCoordinator(Pid, [H|T]) ->
    io:format("~p: sending coordinator message to: ~p ~n", [Pid, H]),
    H ! {coordinator, Pid}, sendCoordinator(Pid, T);
sendCoordinator(Pid, []) ->
    io:format("~p: all coordinator messages sent: ~n", [Pid]).
    

addToGroup(Pid, Group) ->
    IsMem = member(Pid, Group),
    if
        IsMem -> Group;
        true -> append(Group, [Pid])
    end.

% The state of each process contains at least the current coordinator (maybe the own election
% value) and also a list of all other processes in the group.
process(undefined, Group) ->
% hold election
    case sendElection(self(), Group, Group) of 
        unreachable -> process(self(), Group);
        ok ->
            receive
                {coordinator, Pid} -> process(Pid, Group)
            end
    end;
process(Coordinator, Group) ->
    receive
        {election, Pid} -> Pid ! ok, sendElection(self(), Group, Group), process(Coordinator, addToGroup(Pid, Group));
        {coordinator, Pid} -> process(Pid, Group)
    end.



setup() ->
    P1 = spawn(fun() -> process(undefined, []) end),
    P2 = spawn(fun() -> process(undefined, [P1]) end).
