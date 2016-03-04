import 'token';
import 'market';
import 'atc_interface';
import 'ATCE';

contract FlightDoneHandler is MessageHandler {
    DroneEmployeeE master;
    
    function FlightDoneHandler(DroneEmployeeE _master) {
        master = _master;
    }

    function incomingMessage(Message _msg) {
        if (master == msg.sender) {
            master.flightDone();
        }
    }
}

contract DroneEmployeeE is ROSCompatible {
    address creator;
    // Commercy
    token  droneToken;
    token  atcToken;
    market droneMarket;
    ATCE atc;
    address internalDroneAddress;
    // ROS
    Publisher targetPub;
    // Events
    event FlightDown();
    event FlightUp(int latitude, int longitude, int altitude);
    
    function DroneEmployeeE(market _marketAddress, ATCE _atc, 
                            token _atcToken, address _internalAddress) {
        creator = msg.sender;
        droneMarket = _marketAddress;
        atc = _atc;
        atcToken = _atcToken;
        internalDroneAddress = _internalAddress;
        // Aproove atc
        _atcToken.approve(atc);
    }
    
    function init() returns (bool) {
        if (msg.sender != creator) return false;
        return makeToken() && initROS();
    }
    
    function makeToken() returns (bool) {
        // Making a new drone token
        droneToken = new token("TCK", "Cargo Delivery Ticket", 0, this);
        if (!droneToken.emission(1))
            return false;
        // Sell token on market
        droneMarket.addSell(address(droneToken), 1, 2, 1, 1);
        return true;
    }
    
    function initROS() returns (bool) {
        targetPub = mkPublisher('target_request', 'small_atc_msgs/SatFix');
        mkSubscriber('release', 'std_msgs/UInt32', new FlightDoneHandler(this));
        return true;
    }

    function buyATCToken() returns (bool) {
        uint order_id = droneMarket.sellCountAsset(atcToken);
        return droneMarket.dealSell(atcToken, order_id, 1);
    }

    function flightTo(int256 _latitude, int256 _longitude, int256 _altitude) returns (bool) {
        if (!buyATCToken()) return false;
        if (!atc.paymentFor(internalDroneAddress)) return false;
        if (!droneToken.transferFrom(msg.sender, this, 1)) return false;
        targetPub.publish(new SatFix(_latitude, _longitude, _altitude));
        FlightUp(_latitude, _longitude, _altitude);
        return true;
    }
    
    function flightDone() {
        droneMarket.addSell(address(droneToken), 1, 2, 1, 1);
        FlightDown();
    }
}
