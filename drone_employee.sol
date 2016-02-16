import 'atc_interface';

contract DroneEmployee is ROSCompatible, Aircraft {
    Publisher targetPub;
    ATC controller;
    
    event TakeFlight();
    event SetRoute();

    SatFix[] public checkpoints;

    /* Initial */
    function DroneEmployee(ATC _controller) {
        controller = _controller;
        targetPub = mkPublisher("target",
                                'dron_common_msgs/RouteResponse');
    }
    
    function addCheckpoint(int256 latitude, int256 longitude, int256 altitude) {
        checkpoints[checkpoints.length++] =
            new SatFix(latitude, longitude, altitude);
    }
    
    function takeFlight() {
        TakeFlight();
        controller.makeRoute(checkpoints);
    }

    function setRoute(RouteResponse _res) {
        SetRoute();
        
        if (_res.valid())
            targetPub.publish(_res);
            
        delete checkpoints;
    }
}
