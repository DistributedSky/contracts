import 'interface/AirTrafficControllerInterface.sol';
import 'interface/DroneEmployeeInterface.sol';
import 'ros/DroneEmployeeROS.sol';
import 'creator/CreatorToken.sol';
import 'market/Market.sol';

contract DroneEmployee is DroneEmployeeInterface {
    /* Flight regulator */
    AirTrafficControllerInterface atc;

    Market public market;
    Token  public credits;

    /* Price of one drone flight */
    uint public flightPrice = 10;

    function setFlightPrice(uint _price) onlyOwner
    { flightPrice = _price; }
    
    event FlightPlanCreated(address indexed sender, address indexed plan);

    /* Drone Employee contract constructor */
    function DroneEmployee(string  _name,       // Drone name
                           address _baseCoords, // Drone base
                           address _atc,      // Air traffic regulator
                           address _market, address _credits) { // DAO market and token
        name    = _name;
        base    = SatFix(_baseCoords);
        atc     = AirTrafficControllerInterface(_atc);
        market  = Market(_market);
        credits = Token(_credits);

        /* Make a token and place token on the market */
        tickets = CreatorToken.create("DroneEmployee Ticket", "DET", 0, 1);
        placeTicket();
    }

    function placeTicket() internal {
        var lot = new Lot(tickets, credits, 1, flightPrice);
        tickets.approve(lot, 1);
        market.append(lot);
    }

    function buyATCToken() internal returns (bool) {
        /* So drone aleady have positive balance on ATC token */
        if (atc.token().getBalance() > 0) return true;

        Lot found;
        for (var lot = market.first(); lot != Lot(0); lot = market.next(lot)) {
            // Search for the first open lot
            if (lot.seller() == address(atc) && !lot.closed()) {
                found = lot;
                break;
            }
        }

        /* Approve lot and deal */
        credits.approve(found, found.price());
        if (!found.deal()) {
            credits.unapprove(found);
            return false;
        }
        return true;
    }

    function getFlight() returns (FlightPlan) {
        /* Sender have positive balance on drone token */
        if (!tickets.transferFrom(msg.sender, this, 1)) throw;
            
        /* Drone have ATC tokens and ATC payment processed */
        if (!buyATCToken()) throw; 
        atc.token().approve(atc, 1);
        atc.pay(getROSInterface);

        /* Make a flight plan contract */
        var plan = new FlightPlan(getROSInterface);
        getROSInterface.setFlightPlan(plan);
        
        /* Delegate plan to sender */
        plan.delegate(msg.sender);

        /* Return flight plan to sender */
        FlightPlanCreated(msg.sender, plan);
        return plan;
    }

    function flightDone() {
        super.flightDone();
        placeTicket();
    }
}
