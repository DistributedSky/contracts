import 'drone_employee';

contract DroneCarrier is DroneEmployee{
    Publisher pub_dropLat;
    Publisher pub_dropLon;
    
    function DroneCarrier(ATC _controller) DroneEmployee(_controller) {
        pub_dropLat = mkPublisher('drop_target_lat', 'std_msgs/UInt32');
        pub_dropLon = mkPublisher('drop_target_lon', 'std_msgs/UInt32');
    }
    
    function addDropPoint(int256 latitude, int256 longitude, int256 altitude) {
        addCheckpoint(latitude, longitude, altitude);
        pub_dropLat.publish(new StdUInt32(uint32(latitude)));
        pub_dropLon.publish(new StdUInt32(uint32(longitude)));
    }
}
