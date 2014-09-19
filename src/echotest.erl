-module(echotest).
-export([start_server/0]).

-define(TCP_OPTIONS, [binary, {packet, 0}, {active, true}, {reuseaddr, true}]).
-define(PORT, 9001).

start_server() ->
	{ok, ListenSocket} = gen_tcp:listen(?PORT, ?TCP_OPTIONS),
    spawn(fun() -> accept(ListenSocket) end).

accept(ListenSocket) ->
    {ok, AcceptedSocket} = gen_tcp:accept(ListenSocket),
    Pid = spawn(fun() ->
        io:format("Connection accepted ~n", []),
        loop(AcceptedSocket)
    end),
    gen_tcp:controlling_process(AcceptedSocket, Pid),
    accept(ListenSocket).

loop(Socket) ->
    receive
	    {tcp, Socket, Bin} ->
	        gen_tcp:send(Socket, Bin),
	        loop(Socket);
	    {tcp_closed, Socket}->
	        io:format("Socket ~p closed~n", [Socket]);
	    {tcp_error, Socket, Reason} ->
	        io:format("Error on socket ~p reason: ~p~n", [Socket, Reason])
    end.
