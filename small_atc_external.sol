import 'market';
import 'ROS';

contract Address is Message {
    address public data;
    
    function Address(address _data) {
        data = _data;
    }
}

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
        if (msg.sender != creator) return;
        return makeToken() && initROS();
    }
    
    function makeToken() returns (bool) {
        atcToken = new token("ATC", "Air Traffic Control Token", 0, this);
        if (!atcToken.emission(100))
            return false;
        atcMarket.addSell(address(atcToken), 100, 2, 1, 1);
        return true;
    }
    
    function initROS() returns (bool) {
        payedPub = mkPublisher('payed_address', 'std_msgs/String');
        return true;
    }
    
    function paymentFor(address _drone) returns (bool) {
        if (atcToken.transferFrom(msg.sender, this, 1)) {
            payedPub.publish(new Address(_drone));
            return true;
        }
        return false;
    }
}
