-module(ex7).
-export([convert/2, maxitem/1, diff/3]).

convert(X,inch) -> {cm, X * 2.54};
convert(X,cm) -> {inch, X * 0.393701}.

% wenn called with miles: ** exception error: no function clause matching ex7:convert(100,miles) (ex7.erl, line 6)


maxitem([]) -> 0;
maxitem([X|XS]) -> 
    io:format("Current list: ~p~n", [[X|XS]]),
    maxitem(XS,X).

maxitem([], Acc) -> Acc;
% Variante 1:
%maxitem([X|XS], Acc) when X > Acc -> maxitem(XS,X);
%maxitem([_|XS], Acc) -> maxitem(XS,Acc).

% Variante 2:
maxitem([X|XS], Acc) ->
    io:format("Current list/maxitem: {~p,~p}~n", [[X|XS],Acc]),
    if  
        X > Acc -> maxitem(XS,X);
        true -> maxitem(XS,Acc)
    end.

diff(F,X,H) -> 
    (F(X + H) - F(X - H)) / (2*H).

% im terminal:
% > F = fun(X) -> 2*X*X*X - 12*X + 3 end.
% > ex7:diff(F,3,0.001)