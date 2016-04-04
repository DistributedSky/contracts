import 'drone_employee_interface.sol';

contract DroneEmployee is Mortal, DroneEmployeeInterface {
    /* Flight regulator */
    AirTrafficControllerInterface atc;
    /* Drone ROS interface */
    DroneEmployeeROS ros;
    
    uint constant flightPrice = 10;

    /* Drone Employee contract constructor */
    function DroneEmployee(AirTrafficControllerInterface _atc, Market _market, Token _publicToken)
            MarketAgent (_publicToken, _market) {
        atc = _atc;
    }
    
    function makeToken() internal {
        /* Make a token and place token on the market */
        getToken = new Token("DroneEmployee Ticket", "DET");
        getToken.emission(1);
        placeLot(1, flightPrice);
    }
    
    function setROSInterface(DroneEmployeeROS _ros) onlyOwner
    { ros = _ros; }

    function buyATCToken() internal returns (bool) {
        /* So drone aleady have positive balance on ATC token */
        if (atc.getToken().getBalance() > 0) return true;

        /* Search best deal for ATC token */
        var best = getMarket.bestDeal(atc.getToken(), getPublicToken, 1);

        /* No lot found */
        if (best == Lot(0)) return false;

        /* Approve lot and deal */
        getPublicToken.approve(best, best.price());
        if (!best.deal()) {
            getPublicToken.unapprove(best);
            return false;
        }
        return true;
    }

    function flightTo(int256 _latitude, int256 _longitude, int256 _altitude) returns (bool) {
        /* Sender have positive balance on drone token */
        if (getToken.getBalance(msg.sender) > 0) {
            
            /* Drone have ATC tokens and ATC payment processed */
            if (buyATCToken() && atc.paymentFor(ros.getInternal())) {
                /* Transfer ticket to drone */
                getToken.transferFrom(msg.sender, this, 1);
                
                /* Flight by ROS interface */
                ros.flightTo(_latitude, _longitude, _altitude);
                return true;
            }
        }
        return false;
    }

    function flightDone() {
        if (msg.sender == address(ros)) {
            /* Flight done, place token on the market */
            placeLot(1, flightPrice);
        }
    }
}
