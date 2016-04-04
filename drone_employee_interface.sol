import 'market.sol';

/* Base drone contract */
contract DroneEmployeeInterface is MarketAgent {
    /* Try to flight to selected point */
    function flightTo(int256 _latitude, int256 _longitude, int256 _altitude)
        returns (bool);
        
    /* Set ROS interface contract */
    function setROSInterface(DroneEmployeeROS _rosInterface);
    
    /* Done the flight, used by ROS interface */
    function flightDone();
}

/* ROS part of DroneEmployee */
contract DroneEmployeeROS {
    function DroneEmployeeROS(address _internal) { getInternal = _internal; }
    /* Return the private blockchain address of drone contract */
    address public getInternal;
    
    /* Flight to selected point */
    function flightTo(int256 _latitude, int256 _longitude, int256 _altitude);
    
    /* Set up the DroneEmployee contract,
     * used to call `flightDone` */
    function setInterface(DroneEmployeeInterface _interface);
}

contract AirTrafficControllerInterface is MarketAgent {
    /* Take payment from sender for `_drone` account and returns true when all is OK */
    function paymentFor(address _drone) returns (bool);
}

contract AirTrafficControllerROS {
    function payed(address _drone);
}
