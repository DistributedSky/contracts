import 'drone_employee_interface.sol';
import 'drone_employee_ros.sol';

contract DroneEmployee is Mortal, DroneEmployeeInterface {
    /* Flight regulator */
    AirTrafficControllerInterface atc;
    
    /* Price of one drone flight */
    uint constant flightPrice = 10;

    /* Drone Employee contract constructor */
    function DroneEmployee(address _endpoint, // Drone ROS hardware ether address
                           AirTrafficControllerInterface _atc, // Air traffic regulator
                           Market _market, Token _publicToken) // DAO market and token
            MarketAgent (_publicToken, _market) {
        getROSInterface = new DroneEmployeeROS(_endpoint, _atc.getROSInterface());
        atc = _atc;
    }

    function makeToken() internal {
        /* Make a token and place token on the market */
        getToken = new Token("DroneEmployee Ticket", "DET");
        getToken.emission(1);
        placeLot(1, flightPrice);
    }

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

    function getFlight() returns (Flight) {
        /* Sender have positive balance on drone token */
        if (getToken.getBalance(msg.sender) > 0) {
            
            /* Drone have ATC tokens and ATC payment processed */
            if (buyATCToken() && atc.paymentFor(getROSInterface)) {
                /* Transfer ticket to drone */
                getToken.transferFrom(msg.sender, this, 1);
                
                /* Make a flight plan contract */
                var plan = new Flight();
                
                /* Delegate plan to sender */
                plan.delegate(msg.sender);
                
                /* Return flight plan to sender */
                return plan;
            }
        }
        throw;
    }

    function flightDone() {
        if (msg.sender == address(getROSInterface)) {
            /* Flight done, place token on the market */
            placeLot(1, flightPrice);
        }
    }
}
