
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;



import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/presets/ERC20PresetMinterPauser.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/Math.sol";


contract MathContract is Ownable {

   using SafeMath for uint256;
   using Math for uint256;


   // exchange rate informations
   uint exchange_rate_start;
   uint exchange_rate_end;
   uint limit_exchange_rate_end;
   uint limit_exchange_rate_endr;

   uint total_pool_balance_start;
   uint total_pool_balance_end;
   uint total_interest_payments;


   function set_test_parameter() public onlyOwner {
       total_pool_balance_start = 50000;
       total_pool_balance_end = 70000;
       exchange_rate_start =  118186500;
       exchange_rate_end =  148186500;
       total_interest_payments = total_pool_balance_end.sub(total_pool_balance_start);
       limit_exchange_rate_end = limit_exchange_movement();
       limit_exchange_rate_endr = limit_exchange_movement_r();
   }

   function to_aEURs(uint _amount) public view returns (uint256) {
       return _amount.mul(10**8).div(uint(exchange_rate_start));
   }
   function limit_exchange_movement() public view returns (uint256) {
       uint exchange_rt_min = exchange_rate_start.mul(5).div(10);
       uint exchange_rt_max = exchange_rate_start.mul(15).div(10);
       return exchange_rate_end.max(exchange_rt_min).min(exchange_rt_max);
   }
   function limit_exchange_movement_r() public view returns (uint256) {
       uint ratio = exchange_rate_end.mul(10**9).div(exchange_rate_start);
       ratio = ratio.max(5*10**8).min(15*10**8);
       uint normalizer = 2*10**9;
       return normalizer.sub(ratio).div(10);
   }

   function limit_ratio() public view returns (uint256) {
       uint ratio = exchange_rate_end.mul(10**9).div(exchange_rate_start);
       ratio = ratio.max(5*10**8).min(15*10**8);
       return ratio;
   }

   // redeem aEURs tokens
   function _aEURs_to_aDai(uint _amount) public view returns (uint256) {
       uint interest_part = aEURs_interest(_amount);
       uint principal_part = aEURs_to_dollar(_amount);
       return  principal_part.add(interest_part);
   }
   function aEURs_interest(uint _amount) public view returns (uint256) {
       return _amount.mul(exchange_rate_start).mul(total_interest_payments).div(total_pool_balance_start).div(10**8); //
   }
   function aEURs_to_dollar(uint _amount) public view returns (uint256) {
       return _amount.mul(limit_exchange_rate_end).div(10**8);
   }

   // redeem aEURu tokens
   function _aEURu_to_aDai(uint _amount) public view returns (uint256) {
       uint interest_part = aEURu_interest(_amount);
       uint principal_part = aEURu_to_dollar(_amount);
       return  principal_part.add(interest_part);
   }
   function aEURu_interest(uint _amount) public view returns (uint256) {
       return  _amount.mul(total_interest_payments).div(total_pool_balance_start);
   }
   function aEURu_to_dollar(uint _amount) public view returns (uint256) {
       return _amount.mul(limit_exchange_rate_endr).div(10**8);
   }


   // other info
   function show_exchange_rates() public view returns (uint start_rate, uint end_rate, uint limit_rate_one, uint limit_rate_two) {
       start_rate = exchange_rate_start;
       end_rate = exchange_rate_end;
       limit_rate_one = limit_exchange_rate_end;
       limit_rate_two = limit_exchange_rate_endr;
   }

   function show_pool_balances() public view returns (uint start_pool, uint end_pool, uint  interest_pool) {
       start_pool =  total_pool_balance_start;
       end_pool =  total_pool_balance_end;
       interest_pool = total_interest_payments;
   }
}
