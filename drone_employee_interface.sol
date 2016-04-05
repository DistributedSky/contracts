import 'market.sol';
import 'atc_interface.sol';

/* Flight plan contract */
contract Flight is Mortal {
    /* Flight plan checkpoint list */
    Checkpoint[] public checkpoints;
    
    /* Base drone interface */
    DroneEmployeeInterface drone;
    
    /* Make a flight plan and store drone base contract address */
    function Flight() { drone = DroneEmployeeInterface(owner); }

    /* Append new point into plan */
    function append(Checkpoint _checkpoint) onlyOwner
    { checkpoints[checkpoints.length++] = _checkpoint; }
    
    /* Run flight plan on drone */
    function run() onlyOwner
    { drone.getROSInterface().flight(checkpoints); }
}

/* Base drone contract */
contract DroneEmployeeInterface is MarketAgent {
    /* Get flight plan contract */
    function getFlight() returns (Flight);

    /* Get ROS interface contract */
    DroneEmployeeROSInterface public getROSInterface;
    
    /* Done the flight, used by ROS interface */
    function flightDone();
}

/* ROS part of DroneEmployee */
contract DroneEmployeeROSInterface is Aircraft, Mortal {
    /* Current flight plan contract */
    Flight plan;

    /* Set current flight plan */
    function setFlightPlan(Flight _plan) onlyOwner
    { plan = _plan; }

    /* Flight to flight plan points */
    function flight(Checkpoint[] _checkpoints);
}

contract AirTrafficControllerInterface is MarketAgent {
    /* Mapping for payment check */
    mapping (address => bool) public isPaid;

    /* Take payment from sender for `_drone` account and returns true when all is OK */
    function paymentFor(address _drone) returns (bool);
    
    /* Release drone by address */
    function release(address _drone);
    
    /* Get ROS interface contract */
    RouteController public getROSInterface;
}
