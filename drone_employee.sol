import 'atc_interface';

contract RouteReleaseHandler is MessageHandler {
    DroneEmployee master;

    function RouteReleaseHandler(DroneEmployee _master) {
        master = _master;
    }

    function incomingMessage(Message _msg) {
        if (master == msg.sender) {
            StdUInt32 route_id = StdUInt32(_msg);
            master.flightDone(route_id.data());
        }
    }
}

contract DroneEmployee is ROSCompatible, Aircraft {
    SatFix[] public checkpoints;
    Publisher routePub;
    ATC controller;

    /* Initial */
    function DroneEmployee(ATC _controller) {
        controller = _controller;
    }

    function initROS() {
        routePub = mkPublisher('route',
                               'small_atc_msgs/RouteResponse');
        mkSubscriber('remove', 'std_msgs/UInt32', new RouteReleaseHandler(this));
    }
    
    function addCheckpoint(int256 latitude, int256 longitude, int256 altitude) {
        checkpoints[checkpoints.length++] =
            new SatFix(latitude, longitude, altitude);
    }
    
    function takeFlight() {
        controller.makeRoute(checkpoints);
    }

    function flightDone(uint32 _route_id) {
        controller.dropRoute(_route_id);
    }

    function setRoute(RouteResponse _response) {
        if (msg.sender == address(controller)) {
            routePub.publish(_response);
            delete checkpoints;
            checkpoints.length = 0;
        }
    }
}
