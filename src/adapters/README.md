# Adapters 

This folder contains various adapters which will connect the blockchain platform to be tested to Caliper. To enable the test, the below codes also need to be added:
1. Add a new blockchain type in the constructor function of blockchain.js file(src/comm/blockchain.js).
2. The network configuration file's subsection 'blockchain' should be change to your defined blockchain type.
3. Write your own callback which will be claimed in the configuration file and own smart contract.