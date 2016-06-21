import 'interface/AirTrafficControllerInterface.sol';

contract AirTrafficController is Mortal, AirTrafficControllerInterface {
    /* Route controller token price */
    uint routePrice = 100;

    function setRoutePrice(uint _price) onlyOwner
    { routePrice _price; }

    uint constant routeCount = 10;

    Market public market;
    Token  public credits;

    function AirTrafficController(string  _name,
                                  address[] _area,
                                  address _market,
                                  address _credits) {
        name    = _name;
        area    = SatFix[](_area);
        market  = Market(_market);
        credits = Token(_credits);
        token   = TokenCreator.create("ATC Ticket", "ATC", 0, routeCount);
        for (uint i = 0; i < routeCount; i += 1)
            placeToken();
    }

    function placeToken() internal {
        var lot = new Lot(token, credits, 1, routePrice);
        token.approve(lot, 1);
        market.append(lot);
    }

    function pay(address _drone) returns (bool) {
        /* Check payer balance */
        if (!token.transferFrom(_drone, this, 1)) throw;
        
        /* Register address as payed for ROS interface */
        isPaid[_drone] = true;
        return true;
    }
    
    function release(address _drone) {
        /* ROS interface signal about released route */
        if (msg.sender != getROSInterface) throw;

        /* Unregister released address from payed */
        isPaid[_drone] = false;

        /* Place lot on market */
        placeToken();
    }
}
