import 'drone_employee_interface.sol';

contract RouteReleaseHandler is MessageHandler, Mortal {
    function incomingMessage(Message _msg) onlyOwner {
        StdUInt32 route_id = StdUInt32(_msg);
        DroneEmployeeROS(owner).flightDone(route_id.data());
    }
}

contract DroneEmployeeROS is ROSCompatible, DroneEmployeeROSInterface {
    Publisher           routePub;
    RouteController     controller;
    RouteReleaseHandler releaseHandler;

    /* Initial */
    function DroneEmployeeROS(address _endpoint, RouteController _controller) ROSCompatible(_endpoint) {
        controller = _controller;
        routePub = mkPublisher('route', 'small_atc_msgs/RouteResponse');
        releaseHandler = new RouteReleaseHandler();
        mkSubscriber('release', 'std_msgs/UInt32', releaseHandler);
    }

    function flight(Checkpoint[] _checkpoints) {
        if (msg.sender == address(plan))
            controller.makeRoute(_checkpoints);
    }

    function setRoute(RouteResponse _response) {
        if (msg.sender == address(controller))
            routePub.publish(_response);
    }

    function flightDone(uint32 _route_id) {
        if (msg.sender == address(releaseHandler)) {
            controller.dropRoute(_route_id);
            DroneEmployeeInterface(owner).flightDone();
        }
    }
}
