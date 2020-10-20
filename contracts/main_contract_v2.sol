// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;



import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/presets/ERC20PresetMinterPauser.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/Math.sol";

contract MainContract is Ownable {

    using SafeMath for uint256;
    using Math for uint256;

    AggregatorV3Interface internal priceFeed_eur_usd;
    AggregatorV3Interface internal priceFeed_dai_usd;
    /**
     * Network: Kovan
     * Aggregator: 
     * - EUR/USD,  Address: 0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13
     * - DAI/USD,  Address:	0x777A68032a88E5A84678A77Af2CD65A7b3c0775a
     * 
     * 
     */
    constructor() public {
        priceFeed_eur_usd = AggregatorV3Interface(0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13);
        priceFeed_dai_usd = AggregatorV3Interface(0x777A68032a88E5A84678A77Af2CD65A7b3c0775a);
    }

    function getLatestPrice_EUR() public view returns (int) {
        //(
        //    uint80 roundID,
        //    int price,
        //    uint startedAt,
        //    uint timeStamp,
        //    uint80 answeredInRound
        //) = priceFeed_eur_usd.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        //require(timeStamp > 0, "Round not complete");
        //return price; */
        return 118186500;
    }
    function getLatestPrice_Dai() public view returns (int) {
        //(
        //    uint80 roundID,
        //    int price,
        //    uint startedAt,
        //    uint timeStamp,
        //    uint80 answeredInRound
        //) = priceFeed_dai_usd.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        //require(timeStamp > 0, "Round not complete");
        //return price; */
        return 108186500;
    }


    // exchange rate informations
    uint exchange_rate_start;
    uint exchange_rate_end;


    uint total_pre_pool_balance;
    uint total_pool_balance_start;
    uint total_pool_balance_end;

    address aEURs_address;
    address aEURu_address;
    address aDai_address;

    bool round_is_over;
    bool saving_is_over;

    // some random events
    event SetExchangeRate (
        int exchange_rate
    );

    // mappings
    mapping(address => uint) public pre_pool_balances;


    // aEURu and aEURu are both ERC20 tokens
    ERC20PresetMinterPauser public aEURs;
    ERC20PresetMinterPauser public aEURu;
    ERC20 public aDai;

    function get_pre_pool_balance(address _address) public view returns (uint) {
        return pre_pool_balances[_address];
    }

    function start_saving() public onlyOwner {
        round_is_over = true;
        exchange_rate_start = uint(getLatestPrice_EUR());
    }
    
    function start_redeeming() public onlyOwner {
        saving_is_over = true;
        exchange_rate_end = uint(getLatestPrice_EUR());
        total_pool_balance_end = aDai.balanceOf(address(this));
    }


    function fund_pre_pool(uint aDai_amount) public {
        bool success = aDai.transferFrom(msg.sender, address(this), aDai_amount);
        require(success, "buy failed");
        pre_pool_balances[msg.sender] = pre_pool_balances[msg.sender].add(aDai_amount);
        total_pool_balance_start = total_pool_balance_start.add(aDai_amount);
    }

    function mint_tokens() external {
      require(round_is_over, "Can not mint before investment round ended");
      uint aDai_amount = pre_pool_balances[msg.sender];
      pre_pool_balances[msg.sender] = pre_pool_balances[msg.sender].sub(aDai_amount);
      _mint_euro_stable(aDai_amount.div(2));
      _mint_euro_unstable(aDai_amount.div(2));
    }


    // utilities
    function get_contract_adress() public view returns (address) {
        return address(this);
    }
    function get_aEURs_address () public view returns(address) {
        return aEURs_address;
    }
    function get_aEURu_address () public view returns(address) {
        return aEURu_address;
    }
    function get_aDai_address () public view returns(address) {
        return aDai_address;
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


    // mint derivative tokens
    function _mint_euro_stable(uint aDai_amount) internal{
        uint256 aEURs_amount = _aDai_to_aEURs(aDai_amount);
        aEURs.mint(msg.sender,aEURs_amount);
    }
    function _aDai_to_aEURs(uint _amount) internal view returns (uint256) {
        return _amount.mul(10**8).div(uint(exchange_rate_start));
    }

    function _mint_euro_unstable(uint aDai_amount) internal{
        aEURu.mint(msg.sender,aDai_amount);
    }



    // view your current balance
    function get_aEURs_to_Dai(address _address) public view returns (uint256) {
        uint _amount = aEURs.balanceOf(_address);
        require(_amount>0, "Balance is zero");
        return aEURs_to_aDai(_amount, uint(getLatestPrice_EUR()));
    }
    function get_aEURs_to_EUR(address _address) public view returns (uint256) {
        return _Dai_to_EUR(get_aEURs_to_Dai(_address));
    }
    function get_aEURu_to_Dai(address _address) public view returns (uint256) {
        uint _amount = aEURu.balanceOf(_address);
        return aEURu_to_aDai(_amount, uint(getLatestPrice_EUR()));
    }
    function get_aEURu_to_EUR(address _address) public view returns (uint256) {
        return _Dai_to_EUR(get_aEURu_to_Dai(_address));
    }
    
    // redeem derivative tokens
    function redeem_euro_stable(uint aEURs_amount) external{
        require(saving_is_over, "Saving period has not stopped yet");
        uint usd_amount_retail = aEURs_to_aDai(aEURs_amount, exchange_rate_end);
        aEURs.burnFrom(msg.sender, aEURs_amount);
        aDai.transfer(msg.sender, usd_amount_retail);
    }

    function redeem_euro_unstable(uint aEURu_amount) external{
        require(saving_is_over, "Saving period has not stopped yet");
        uint usd_amount_hedger = aEURu_to_aDai(aEURu_amount, exchange_rate_end);
        aEURu.burnFrom(msg.sender, aEURu_amount);
        aDai.transfer(msg.sender, usd_amount_hedger);
    }


    // redeem aEURs tokens
    function aEURs_to_aDai(uint _amount, uint _exchange_rate) public view returns (uint256) {
        uint interest_part = aEURs_interest(_amount, exchange_rate_start);
        uint principal_part = aEURs_to_dollar(_amount, limit_exchange_movement_long(_exchange_rate));
        return  principal_part.add(interest_part);
    }
    function aEURs_interest(uint _amount, uint _exchange_rate) internal view returns (uint256) {
        return _amount.mul(_exchange_rate).mul(total_pool_balance_end.sub(total_pool_balance_start)).div(total_pool_balance_start).div(10**8); //
    }
    function aEURs_to_dollar(uint _amount, uint _exchange_rate) internal pure returns (uint256) {
        return _amount.mul(_exchange_rate).div(10**8);
    }

    // redeem aEURu tokens
    function aEURu_to_aDai(uint _amount, uint _exchange_rate) public view returns (uint256) {
        uint interest_part = aEURu_interest(_amount);
        uint principal_part = aEURu_to_dollar(_amount, _exchange_rate);
        return  principal_part.add(interest_part);
    }
    function aEURu_interest(uint _amount) internal view returns (uint256) {
        return  _amount.mul(total_pool_balance_end.sub(total_pool_balance_start)).div(total_pool_balance_start);
    }
    function aEURu_to_dollar(uint _amount, uint _exchange_rate) internal view returns (uint256) {
        return _amount.mul(limit_exchange_movement_short(_exchange_rate)).div(10**8);
    }
    
    // exchange rate conversion helper 
    function _Dai_to_EUR(uint _amount) internal view returns (uint256) {
        return _amount.mul(uint(getLatestPrice_EUR())).div(uint(getLatestPrice_Dai()));
    }
    function _Dai_to_USD(uint _amount) internal view returns (uint256) {
        return _amount.mul(uint(getLatestPrice_Dai())).div(10**8);
    }

    // limit exchange rate movements hedged by the contract to 50% up/down
    function limit_exchange_movement_long(uint _exchange_rt) internal view returns (uint256) {
        uint exchange_rt_min = exchange_rate_start.mul(5).div(10);
        uint exchange_rt_max = exchange_rate_start.mul(15).div(10);
        return _exchange_rt.max(exchange_rt_min).min(exchange_rt_max);
    }
    function limit_exchange_movement_short(uint _exchange_rt) internal view returns (uint256) {
        uint ratio = _exchange_rt.mul(10**9).div(exchange_rate_start);
        ratio = ratio.max(5*10**8).min(15*10**8);
        uint normalizer = 2*10**9;
        return normalizer.sub(ratio).div(10);
    }
    // other utility functions
    function show_exchange_rates() public view returns (uint _exchange_rate_start, uint _exchange_rate_end) {
        _exchange_rate_start = exchange_rate_start;
        _exchange_rate_end = exchange_rate_end;
    }

    function show_pool_balances() public view returns (uint  _total_pool_balance_start, uint _total_pool_balance_end) {
        _total_pool_balance_start =  total_pool_balance_start;
        _total_pool_balance_end =  total_pool_balance_end;
    }
    
    function is_saving_over() public view returns (bool) {
            return saving_is_over;
    }
    function is_round_over() public view returns (bool) {
            return round_is_over;
    }
    
}
