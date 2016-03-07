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
    token  public droneToken;
    market public droneMarket;
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
        atc.atcToken().approve(atc);
        internalDroneAddress = _internalAddress;
        creator = msg.sender;
    }

    function init() returns (bool) {
        if (msg.sender != creator) return false;
        // Making a new drone token
        droneToken = new token("TCK", "Cargo Delivery Ticket", 0, this);
        if (!droneToken.emission(1))
            return false;
        // Sell token on market
        droneToken.approve(droneMarket);
        droneMarket.addSell(address(droneToken), 1, 2, 1, 1);
        // Init ROS
        targetPub = mkPublisher('target_request', 'small_atc_msgs/SatFix');
        mkSubscriber('release', 'std_msgs/UInt32', new FlightDoneHandler(this));
        return true;
    }

    function buyATCToken() private returns (bool) {
        if (atc.atcToken().getBalance(this) > 0) return true;
        uint order_id = droneMarket.sellCountAsset(atc.atcToken());
        return droneMarket.dealSell(atc.atcToken(), order_id, 1);
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
