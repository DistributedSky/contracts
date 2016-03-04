import 'atc_interface';

contract TargetRequestHandler is MessageHandler {
    DroneEmployeeI master;
    
    function TargetRequestHandler(DroneEmployeeI _master) {
        master = _master;
    }

    function incomingMessage(Message _msg) {
        if (master == msg.sender) {
            SatFix target = SatFix(_msg);
            master.flightTo(target);
        }
    }
}

contract RouteReleaseHandler is MessageHandler {
    DroneEmployeeI master;

    function RouteReleaseHandler(DroneEmployeeI _master) {
        master = _master;
    }

    function incomingMessage(Message _msg) {
        if (master == msg.sender) {
            StdUInt32 route_id = StdUInt32(_msg);
            master.flightDone(route_id.data());
        }
    }
}

contract DroneEmployeeI is ROSCompatible, Aircraft {
    SatFix[] public checkpoints;
    Publisher routePub;
    ATC controller;

    /* Initial */
    function DroneEmployeeI(ATC _controller, SatFix _home) {
        controller = _controller;
        checkpoints.length = 2;
        checkpoints[0] = _home;
    }

    function initROS() {
        routePub = mkPublisher('route',
                               'small_atc_msgs/RouteResponse');
        mkSubscriber('release', 'std_msgs/UInt32', new RouteReleaseHandler(this));
        mkSubscriber('target_request', 'small_atc_msgs/SatFix', new TargetRequestHandler(this));
    }
    
    function flightTo(SatFix _target) {
        checkpoints[1] = _target;
        controller.makeRoute(checkpoints);
    }

    function flightDone(uint32 _route_id) {
        controller.dropRoute(_route_id);
    }

    function setRoute(RouteResponse _response) {
        if (msg.sender == address(controller)) {
            routePub.publish(_response);
        }
    }
}
