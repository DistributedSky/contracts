import 'token';
import 'market';
import 'atc_interface';
import 'small_atc_external';

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
    // Commercy
    token  droneToken;
    market droneMarket;
    ATCE atc;
    address internalDroneAddress;
    address creator;
    // ROS
    Publisher targetPub;
    // Events
    event FlightDown();
    event FlightUp(int latitude, int longitude, int altitude);

    function DroneEmployeeE(market _marketAddress, ATCE _atc, address _internalAddress) {
        droneMarket = _marketAddress;
        atc = _atc;
        internalDroneAddress = _internalAddress;
        creator = msg.sender;
        // Aproove atc
        atc.getToken().approve(atc);
    }

    function init() returns (bool) {
        if (msg.sender != creator) return false;
        return makeToken() && initROS();
    }

    function makeToken() private returns (bool) {
        // Making a new drone token
        droneToken = new token("TCK", "Cargo Delivery Ticket", 0, this);
        if (!droneToken.emission(1))
            return false;
        // Sell token on market
        droneMarket.addSell(address(droneToken), 1, 2, 1, 1);
        return true;
    }

    function initROS() private returns (bool) {
        targetPub = mkPublisher('target_request', 'small_atc_msgs/SatFix');
        mkSubscriber('release', 'std_msgs/UInt32', new FlightDoneHandler(this));
        return true;
    }

    function buyATCToken() private returns (bool) {
        if (atc.getToken().getBalance(this) > 0) return true;
        uint order_id = droneMarket.sellCountAsset(atc.getToken());
        return droneMarket.dealSell(atc.getToken(), order_id, 1);
    }

    function getToken() constant returns (token) {
        return droneToken;
    }

    function flightTo(int256 _latitude, int256 _longitude, int256 _altitude) returns (bool) {
        if (!droneToken.transferFrom(msg.sender, this, 1)) return false;
        if (!buyATCToken() || !atc.paymentFor(internalDroneAddress)) {
            droneToken.transfer(msg.sender, 1);
            return false;
        }
        targetPub.publish(new SatFix(_latitude, _longitude, _altitude));
        FlightUp(_latitude, _longitude, _altitude);
        return true;
    }

    function flightDone() {
        droneMarket.addSell(address(droneToken), 1, 2, 1, 1);
        FlightDown();
    }
}
