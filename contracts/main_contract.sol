// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;



import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/presets/ERC20PresetMinterPauser.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/Math.sol";

contract MainContract is Ownable {

    using SafeMath for uint256;
    using Math for uint256;

    AggregatorV3Interface internal priceFeed;
    /**
     * Network: Kovan
     * Aggregator: EUR/USD
     * Address: 0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13);
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
    uint exchange_rate_start;
    uint exchange_rate_end;
    uint limit_exchange_rate_end;
    uint limit_exchange_rate_endr;

    uint total_pool_balance_start;
    uint total_pool_balance_end;
    uint total_interest_payments;

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



    function start_saving() public onlyOwner {
        round_is_over = true;
        exchange_rate_start = uint(getLatestPrice());
    }

    function start_redeeming() public onlyOwner {
        saving_is_over = true;
        exchange_rate_end = uint(getLatestPrice());
        limit_exchange_rate_end = exchange_rate_end;
        limit_exchange_rate_endr = exchange_rate_end.mul(10**8).div(exchange_rate_start);
        //limit_exchange_rate_end = min(max(exchange_rate_end,exchange_rate_start.mul(1)),exchange_rate_start.mul(1));
        //limit_exchange_rate_endr = max(min(exchange_rate_end.mul(10**8).div(exchange_rate_start),15*10**7),5*10**7);
        total_pool_balance_end = aDai.balanceOf(address(this));
        total_interest_payments = total_pool_balance_end.sub(total_pool_balance_start);
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

    // redeem derivative tokens
    function redeem_euro_stable(uint aEURs_amount) external{
        require(saving_is_over, "Saving period has not stopped yet");
        uint usd_amount_retail = _aEURs_to_aDai(aEURs_amount);
        // aEURs.burn(aEURs_amount);
        aEURs.transfer(address(this), aEURs_amount);
        aDai.transfer(msg.sender, usd_amount_retail);
    }

    function redeem_euro_unstable(uint aEURu_amount) external{
        require(saving_is_over, "Saving period has not stopped yet");
        uint usd_amount_hedger = _aEURu_to_aDai(aEURu_amount);
        //aEURu.burn(aEURu_amount);
        aEURu.transfer(address(this), aEURu_amount);
        aDai.transfer(msg.sender, usd_amount_hedger);
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


    // redirect interest to contract
    //function is_not_redirected() internal returns (bool) {
    //    return aDai.getInterestRedirectionAddress(msg.sender) == 0x0000000000000000000000000000000000000000
    //}

    // mint derivative tokens
    function _mint_euro_stable(uint aDai_amount) internal{
        uint256 aEURs_amount = _to_aEURs(aDai_amount);
        aEURs.mint(msg.sender,aEURs_amount);
    }
    function _to_aEURs(uint _amount) public returns (uint256) {
        return _amount.mul(10**8).div(uint(exchange_rate_start));
    }

    function _mint_euro_unstable(uint aDai_amount) internal{
        aEURs.mint(msg.sender,aDai_amount);
    }

    // redeem tokens

    function _aEURs_to_aDai(uint _amount) public returns (uint256) {
        uint token_share = _amount.mul(exchange_rate_start).mul(10**18).div(total_pool_balance_start);
        return  _amount.mul(10**8).div(uint(limit_exchange_rate_end)) + token_share.mul(total_interest_payments).div(10**18);
    }

    function _aEURu_to_aDai(uint _amount) public returns (uint256) {
        uint token_share = _amount.mul(10**18).div(total_pool_balance_start);
        return  _amount.mul(2*10**8).sub(limit_exchange_rate_endr) + token_share.mul(total_interest_payments).div(10**18);
    }

    function show_exchange_rates() public view returns (uint start_rate, uint end_rate) {
        start_rate = exchange_rate_start;
        end_rate = exchange_rate_end;
    }

    function show_pool_balances() public view returns (uint start_pool, uint end_pool) {
        start_pool =  total_pool_balance_start;
        end_pool =  total_pool_balance_end;
    }
}
