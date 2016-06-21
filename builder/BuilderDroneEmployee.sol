//
// AIRA Builder for DroneEmployee contract
//
//

import 'creator/CreatorDroneEmployee.sol';
import 'creator/CreatorDroneEmployeeROS.sol';
import 'builder/Builder.sol';

/**
 * @title BuilderDroneEmployee contract
 */
contract BuilderDroneEmployee is Builder {
    function BuilderDroneEmployee(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _name is a drone name
     * @param _baseCoords is a drone base coordinate
     * @param _atc is an ATC contract
     * @param _market is market for trading
     * @param _credits is a traded token
     * @param _endpoint is a drone hardware endpoint address
     * @return address new contract
     */
    function create(string _name,
                    SatFix _baseCoords,
                    AirTrafficControllerInterface _atc,
                    Market _market,
                    Token _credits,
                    address _endpoint) returns (address) {
        var inst = CreatorDroneEmployee.create(_name, _baseCoords, _atc, _market, _credits);
        var ros  = CreatorDroneEmployeeROS.create(_endpoint, _atc.getROSInterface(), inst); 

        ros.delegate(inst);
        inst.setROSInterface(ros);
        inst.delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
