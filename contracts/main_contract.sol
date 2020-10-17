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
        //(
        //    uint80 roundID,
        //    int price,
        //    uint startedAt,
        //    uint timeStamp,
        //    uint80 answeredInRound
        //) = priceFeed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        //require(timeStamp > 0, "Round not complete");
        //return price; */
        return 118186500;
    }

    // exchange rate informations
    int exchange_rate;
    address aEURs_address;
    address aEURu_address;
    address aDai_address;


    // some random events
    event ChangedExchangeRate (
        int _old_rate,
        int _new_rate
    );

    // mappings
    mapping(address => uint) public principal_balances;
    mapping(address => uint) public total_balance;
    mapping(address => uint) public interest_balance;


    // aEURu and aEURu are both ERC20 tokens
    ERC20PresetMinterPauser public aEURs;
    ERC20PresetMinterPauser public aEURu;
    ERC20 public aDai;

    function mint_tokens(uint aDai_amount) external {
      bool redirected = is_not_redirected();
      require(success, "Redirection of interest rates is not allowed");

      _update_exchange_rate();
      _mint_euro_stable(aDai_amount.div(2));
      _mint_euro_unstable(aDai_amount.div(2));
    }

    function end_redirection() external {
      aDai.redirectInterestStream(0x0000000000000000000000000000000000000000);
    }

    // redeem derivative tokens
    function redeem_euro_stable(uint aEURs_amount) external{
        uint usd_amount_retail = aEURs_to_aDai(aEURs_amount);
        aEURs.burn(aEURs_amount);
        aDai.transfer(msg.sender, usd_amount_retail);
    }


    function redeem_euro_unstable(uint aEURu_amount) external{
        uint usd_amount_hedger = aEURu_to_aDai(aEURu_amount);
        aEURu.burn(aEURu_amount);
        aDai.transfer(msg.sender, usd_amount_hedger);
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

    function _aEURu_to_aDai(uint _amount) internal returns (uint256) {
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

    // redirect interest to contract
    //function is_not_redirected() internal returns (bool) {
    //    return aDai.getInterestRedirectionAddress(msg.sender) == 0x0000000000000000000000000000000000000000
    //}

    // mint derivative tokens
    function _mint_euro_stable(uint aDai_amount) internal{
        uint256 aEURs_amount = to_aEURs(aDai_amount);
        bool success = aDai.transferFrom(msg.sender, address(this), aDai_amount);
        require(success, "buy failed");
        aEURs.mint(msg.sender,aEURs_amount);
    }
    function _to_aEURs(uint _amount) internal returns (uint256) {
        _update_exchange_rate();
        return _amount.mul(10**8).div(uint(exchange_rate));
    }

    function _mint_euro_unstable(uint aDai_amount) internal{
        bool success = aDai.transferFrom(msg.sender, address(this), aDai_amount);
        require(success, "buy failed");
        aEURs.mint(msg.sender,aDai_amount);
    }

    function _aEURs_to_aDai(uint _amount) internal returns (uint256) {
        return _amount.mul(10**8).div(uint(exchange_rate));
    }
}
