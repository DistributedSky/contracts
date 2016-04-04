import 'drone_employee_interface.sol';

contract AirTrafficController is Mortal, AirTrafficControllerInterface {
    /* ATC ROS interface */
    AirTrafficControllerROS ros;
    
    uint constant routePrice = 100;

    function AirTrafficController(Market _market, Token _publicToken)
            MarketAgent(_publicToken, _market) {}

    function makeToken() internal {
        /* Make a token and place token on the market */
        getToken = new Token("ATC Ticket", "ATC");
        getToken.emission(10);
        for (uint i = 0; i < 10; i += 1)
            placeLot(1, routePrice);
    }

    function setROSInterface(AirTrafficControllerROS _ros) onlyOwner
    { ros = _ros; }

    function paymentFor(address _drone) returns (bool) {
        if (getToken.getBalance(_drone) > 0) {
            getToken.transferFrom(_drone, this, 1);
            ros.payed(_drone);
            return true;
        }
        return false;
    }
    
    function released() {
        /* ROS interface signal about released route */
        if (msg.sender == address(ros)) {
            placeLot(1, routePrice);
        }
    }
}
