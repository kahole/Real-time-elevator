-module(state_poller).

-export([start/1]).

start(Pid, Elevator) ->
    register(state_poller, spawn(fun() -> poller(Pid, Elevator) end)).

poller(Pid, State) ->
    % Polles new state and merges with existing
    CabCalls = get_cab_calls(Pid, [], length(State#elevator.cabRequests)-1),


    % TODO: Ta et steg tilbake og design hele saken først

    % Get floor number. Ignores between_floor
    % TODO: remove the duplicate request
    AtFloor = case elevator_interface:get_floor_sensor_state(Pid) of
        between_floors -> State#elevator.floor;
        _ -> elevator_interface:get_floor_sensor_state(Pid)
    end,

    _State = State#elevator{
        floor=AtFloor,
        cabRequests=[A or B || {A,B} <- lists:zip(State#elevator.cabRequests, CabCalls)]
    },

    receive
        {Sender, get_state} -> 
            Sender ! {updated_state, _State};
        {_, NewState} ->
            poller(Pid, NewState#elevator{
                floor=AtFloor,
                cabRequests=[A or B || {A,B} <- lists:zip(NewState#elevator.cabRequests, Polled_panel_state)]
            })
    end,
    poller(Pid, _State).

get_cab_calls(Pid, Floor_list, 0) ->
    Floor_state = elevator_interface:get_order_button_state(Pid, 0, cab),
    [A == 1 || A <- lists:append([Floor_state], Floor_list)];

get_cab_calls(Pid, Floor_list, Floor_number) -> 
    Floor_state = elevator_interface:get_order_button_state(Pid, Floor_number, cab),
    poll_cab_calls(Pid, lists:append([Floor_state], Floor_list), Floor_number-1).
