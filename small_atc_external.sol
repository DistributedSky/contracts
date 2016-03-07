import 'market';
import 'atc_interface';
import 'ROS';

contract ATCE is ROSCompatible {
    token  public atcToken;
    market public atcMarket;
    address creator;
    
    Publisher payedPub;
    
    function ATCE(market _marketAddress) {
        atcMarket = _marketAddress;
        creator = msg.sender;
    }
    
    function init() {
        if (msg.sender != creator) return;
        // Making token
        atcToken = new token("ATC", "Air Traffic Control Token", 0, this);
        if (!atcToken.emission(100)) return;
        // Sell on the market
        atcToken.approve(atcMarket);
        atcMarket.addSell(address(atcToken), 100, 1, 1, 1);
        // Init ROS functionality
        payedPub = mkPublisher('payed_address', 'small_atc_msgs/Address');
    }
    
    function paymentFor(address _drone) returns (bool) {
        if (atcToken.transferFrom(msg.sender, this, 1)) {
            payedPub.publish(new MsgAddress(_drone));
            return true;
        }
        return false;
    }
}
