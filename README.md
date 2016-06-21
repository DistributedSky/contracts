# DroneEmployee Ethereum contracts

This repositury contains *Ethereum* DApps for **DroneEmployee** project.

## Deploy with AIRA Deploy

Clone [aira_ros_bridge](https://github.com/airalab/aira_ros_bridge), [airalab/core](https://github.com/airalab/core) and this.

Run in **airalab/core**:

    $ ./aira_deploy.sh -O -I ../contracts:../aira_ros_bridge/aira_ros_bridge -C ${CONTRACT}

*Set arguments according to contract constructor.*

