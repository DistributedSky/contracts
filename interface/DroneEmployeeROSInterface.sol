import './FlightPlan.sol';

/* ROS part of DroneEmployee */
contract DroneEmployeeROSInterface is Aircraft, Owned {
    /* Current flight plan contract */
    FlightPlan flightPlan;

    /* Set current flight plan */
    function setFlightPlan(FlightPlan _plan) onlyOwner
    { plan = _plan; }

    /* Flight to flight plan points */
    function flight(Checkpoint[] _checkpoints) {
        if (msg.sender != flightPlan) throw;
    }
}
