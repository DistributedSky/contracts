import 'drone_employee_interface.sol';
import 'air_traffic_controller_ros.sol';

contract AirTrafficController is Mortal, AirTrafficControllerInterface {
    /* Route controller token price */
    uint constant routePrice = 100;

    function AirTrafficController(address _endpoint, Market _market, Token _publicToken)
            MarketAgent(_publicToken, _market) {
        getROSInterface = new AirTrafficControllerROS(_endpoint);
    }

    function makeToken() internal {
        /* Make a token and place token on the market */
        getToken = new Token("ATC Ticket", "ATC");
        getToken.emission(10);
        for (uint i = 0; i < 10; i += 1)
            placeLot(1, routePrice);
    }

    function paymentFor(address _drone) returns (bool) {
        /* Check payer balance */
        if (getToken.getBalance(_drone) > 0) {
            /* Transfer token */
            getToken.transferFrom(_drone, this, 1);

            /* Register address as payed for ROS interface */
            isPaid[_drone] = true;
            return true;
        }
        return false;
    }
    
    function release(address _drone) {
        /* ROS interface signal about released route */
        if (msg.sender == address(getROSInterface)) {
            /* Unregister released address from payed */
            isPaid[_drone] = false;
            
            /* Place lot on market */
            placeLot(1, routePrice);
        }
    }
}
