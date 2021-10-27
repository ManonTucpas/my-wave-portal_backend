// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;
    /*
     *  Event is an inheritable member of a contract. An event is emitted, it stores the arguments passed in transaction logs.   
     *  These logs are stored on blockchain and are accessible using address of the contract 
     *  till the contract is present on the blockchain. 
    */  
    event NewWave(
		address indexed from,
		uint256 timestamp,
		string message,
		bool winner,
		uint256 totalWaves
	);    
    /*
    *  Creation of struct named Wave
    *  A struc is a custom datatype where we can customize what we want inside it. 
    */
    struct Wave {
        address waver; // the address of the user who waved
        string message; // the message the user sent
        uint256 timestamp; // the timestamp when the user waved 
        bool winner;
    }

    /*
    *   Declaration of a variable waves that lets store an array of structs
    *   This is what lets hold all the waves anyone send to me
    */
    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
     mapping(address=> uint256) public lastWavedAt;

    constructor() payable {
        console.log("I AM A SMART CONTRACT");
    /*
    *  Set the initial seed (a random number)
    */
    seed =  (block.timestamp + block.difficulty) % 100;
    }    
    
    /*
    *   Now it requires a string called_message. This is the message 
    *   user sends us from the waveportal website
    */
    function wave(string memory _message) public {

        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "You must wait 30 sec"
        );
        /*
        *   Update the current timestamp we have for the user
        */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
         // msg.sender is the address of the person who has waved, then called the funtcion
        console.log("%s has waved", msg.sender);

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        bool winner = false;
        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50){
            console.log("%s won!", msg.sender);

        uint256 prizeAmount = 0.0001 ether;
        require(
            prizeAmount <= address(this).balance,
            "Trying to withdraw money than the contract has."
        );
        (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        require(success, "Failed to withdraw money from contract.");
        }

        /*
		 * This is where I actually store the wave data in the array.
		 */
		waves.push(Wave(msg.sender, _message, block.timestamp, winner));

        /*
        *   Emit keyword is used to emit an event in solidity,
        *   which can be read by the client in Dapp. Here in our js website
        */
        emit NewWave(msg.sender, block.timestamp, _message, winner, totalWaves);
    }
     

    /*
    *   This function will return the struct array, waves, to us
    *   This will make it easy to retrive the waves from our website
    */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}