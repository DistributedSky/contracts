import 'market';
import 'atc_interface';
import 'ROS';

contract ATCE is ROSCompatible {
    token  atcToken;
    market atcMarket;
    address creator;

    Publisher payedPub;

    function ATCE(market _marketAddress) {
        atcMarket = _marketAddress;
        creator = msg.sender;
    }

    function init() returns (bool) {
        if (msg.sender != creator) return false;
        return makeToken() && initROS();
    }

    function makeToken() private returns (bool) {
        atcToken = new token("ATC", "Air Traffic Control Token", 0, this);
        if (!atcToken.emission(100))
            return false;
        atcMarket.addSell(address(atcToken), 100, 2, 1, 1);
        return true;
    }

    function initROS() private returns (bool) {
        payedPub = mkPublisher('payed_address', 'small_atc_msgs/Address');
        return true;
    }

    function getToken() constant returns (token) {
        return atcToken;
    }

    function paymentFor(address _drone) returns (bool) {
        if (atcToken.transferFrom(msg.sender, this, 1)) {
            payedPub.publish(new MsgAddress(_drone));
            return true;
        }
        return false;
    }
}
