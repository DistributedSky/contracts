import 'atc_interface';

contract ResponseListener is MessageHandler {
    address[] public clients;

    function newRequest(address _addr) returns (uint32) {
        clients[clients.length++] = _addr;
        return uint32(clients.length);
    }

    function incomingMessage(Message _msg) {
        RouteResponse res = RouteResponse(_msg);
        Aircraft(clients[res.id() - 1]).setRoute(res);
    }
}

contract ATCI is ROSCompatible, ATC {
    Publisher   route_request;
    Publisher   route_remover;
    ResponseListener listener;

    function ATCI() {
        route_request = mkPublisher('route/request',
                                    'small_atc_msgs/RouteRequest');
        route_remover = mkPublisher('route/remove', 'std_msgs/UInt32');
        listener = new ResponseListener();
        mkSubscriber('route/response',
                     'small_atc_msgs/RouteResponse',
                     listener);
    }

    function makeRoute(SatFix[] _checkpoints) {
        uint32 id = listener.newRequest(msg.sender);
        route_request.publish(new RouteRequest(_checkpoints, id, new MsgAddress(msg.sender)));
    }

    function dropRoute(uint32 _id) {
        if (listener.clients(_id) == msg.sender)
            route_remover.publish(new StdUInt32(_id));
    }
}
