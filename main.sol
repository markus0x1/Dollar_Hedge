/** This example code is designed to quickly deploy an example contract using Remix.
 *  If you have never used Remix, try our example walkthrough: https://docs.chain.link/docs/example-walkthrough
 *  You will need testnet ETH and LINK.
 *     - Kovan ETH faucet: https://faucet.kovan.network/
 *     - Kovan LINK faucet: https://kovan.chain.link/
 */

pragma solidity ^0.6.7;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/presets/ERC20PresetMinterPauser.sol";

contract MainContract {

     using SafeMath for uint256;

    AggregatorV3Interface internal priceFeed;
    ERC20PresetMinterPauser internal aEURs;
    /**
     * Network: Kovan
     * Aggregator: EUR/USD
     * Address: 0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13);
    }

    mapping(address => uint) public aUSDCbalance;
    mapping(address => uint) public aEURsbalance;
    mapping(address => uint) public aEURubalance;

    int exchange_rate;
    address eurs_token_address;
    event ChangedExchangeRate (
        int _old_rate,
        int _new_rate
    );
    /**
     * Returns the latest price
     */
    function get_token_address () public view returns(address) {
        return eurs_token_address;
    }

    function set_token_address (address new_token_address) public {
        eurs_token_address = new_token_address;
        aEURs = ERC20PresetMinterPauser(eurs_token_address);
    }

    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        return price;
    }

    function update_exchange_rate () public {
        int  old_exchange_rate = exchange_rate;
        exchange_rate = getLatestPrice();
        emit ChangedExchangeRate (old_exchange_rate, exchange_rate);
    }

    function mint_euro_stable(address _to, uint _amount) public {
        update_exchange_rate();
        uint eur_amount = _amount.mul(uint(exchange_rate)).mod(10**8);
        aEURs.mint(_to,eur_amount);
    }
    function get_exchange_rate() public view returns (int) {
        return exchange_rate;
    }

}
