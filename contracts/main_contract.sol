// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/presets/ERC20PresetMinterPauser.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/access/Ownable.sol";

contract MainContract is Ownable {

    using SafeMath for uint256;

    AggregatorV3Interface internal priceFeed;
    /**
     * Network: Kovan
     * Aggregator: EUR/USD
     * Address: 0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13);
        exchange_rate = 118186500;
    }

    function getLatestPrice() public view returns (int) {
        /*(
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        return price; */
        return 118186500;
    }

    // exchange rate informations
    int exchange_rate;
    int tau;
    address aEURs_address;
    address aEURu_address;
    address aDai_address;


    // some random events
    event ChangedExchangeRate (
        int _old_rate,
        int _new_rate
    );
    event minted_aEURs (
        int _current_exchange_rate,
        address _minter_address,
        uint _minted_amount
    );
    event minted_aEURu (
        int _current_exchange_rate,
        address _minter_address,
        uint _minted_amount
    );
    event redeemed_aEURu (
        int _current_exchange_rate,
        address _minter_address,
        uint _minted_amount
    );
    event redeemed_aEURs (
        int _current_exchange_rate,
        address _minter_address,
        uint _minted_amount
    );
    // mappings

    // aEURu and aEURu are both ERC20 tokens
    ERC20PresetMinterPauser public aEURs;
    ERC20PresetMinterPauser public aEURu;
    ERC20 public aDai;


    // mint derivative tokens
    function mint_euro_stable(uint aDai_amount) external{
        uint256 aEURs_amount = to_aEURs(aDai_amount);
        bool success = aDai.transferFrom(msg.sender, address(this), aDai_amount);
        require(success, "buy failed");
        aEURs.mint(msg.sender,aEURs_amount);
    }
    function to_aEURs(uint _amount) internal returns (uint256) {
        _update_exchange_rate();
        return _amount.mul(10**8).div(uint(exchange_rate));
    }

    function mint_euro_unstable(uint aDai_amount) external{
        bool success = aDai.transferFrom(msg.sender, address(this), aDai_amount);
        require(success, "buy failed");
        aEURs.mint(msg.sender,aDai_amount);
    }

    // redeem derivative tokens
    function redeem_euro_stable(uint aEURs_amount) external{
        uint usd_amount_retail = aEURs_to_aDai(aEURs_amount);
        aEURs.burn(aEURs_amount);
        aDai.transfer(msg.sender, usd_amount_retail);
    }
    function aEURs_to_aDai(uint _amount) internal returns (uint256) {
        _update_exchange_rate();
        return _amount.mul(10**8).div(uint(exchange_rate));
    }

    function redeem_euro_unstable(uint aEURu_amount) external{
        uint usd_amount_hedger = aEURu_to_aDai(aEURu_amount);
        aEURu.burn(aEURu_amount);
        aDai.transfer(msg.sender, usd_amount_hedger);
    }
    function aEURu_to_aDai(uint _amount) internal returns (uint256) {
        _update_exchange_rate();
        uint usd_amount_retail = _amount.mul(10**8).div(uint(exchange_rate));
        return  _amount.mul(2).sub(usd_amount_retail);
    }

    // change exchange rate information
    function _update_exchange_rate () internal {
        int  old_exchange_rate = exchange_rate;
        exchange_rate = getLatestPrice();
        // to do: only update if exchange rate did change
        emit ChangedExchangeRate (old_exchange_rate, exchange_rate);
    }

    // exchange rate information
    function get_exchange_rate() public view returns (int) {
        return exchange_rate;
    }


    // utilities
    function get_contract_adress() public view returns (address) {
        return address(this);
    }


    // set new address (used for testing)
    function set_aEURs_address (address new_token_address) public onlyOwner {
        aEURs_address = new_token_address;
        aEURs = ERC20PresetMinterPauser(aEURs_address);
    }
    function set_aEURu_address (address new_token_address) public onlyOwner {
        aEURu_address = new_token_address;
        aEURu = ERC20PresetMinterPauser(new_token_address);
    }
    function set_aDai_address (address new_token_address) public onlyOwner {
        aDai_address = new_token_address;
        aDai = ERC20(new_token_address);
    }
    // return information about address
    function get_aEURs_address () public view returns(address) {
        return aEURs_address;
    }
    function get_aEURu_address () public view returns(address) {
        return aEURu_address;
    }
    function get_aDai_address () public view returns(address) {
        return aDai_address;
    }

}
