// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract sharedWallet is Ownable{

      using SafeMath for uint;

      event AllowanceChanged(address indexed _forWho,address indexed _byWhom,uint _oldAmount, uint _newAmount);
      event MoneySent(address indexed _beneficiary,uint _amount);
      event MoneyReceived(address indexed _from,uint _amount);


      mapping(address=>uint) public allowance;
      

      
      modifier ownerOrAllowed(uint _amount){
         require(msg.sender==owner() || allowance[msg.sender]>=_amount,"you are not allowed");
          _;
      }


      function setAllowance(address _who,uint _amount) external onlyOwner{
      emit AllowanceChanged(_who,msg.sender,allowance[_who],_amount);
      allowance[_who]=_amount;
      }
      

      function reduceAllowance(address _who,uint _amount)public onlyOwner{
          emit AllowanceChanged(_who,msg.sender,allowance[_who],allowance[_who].sub(_amount));
          allowance[_who].sub(_amount);

      }


      function withdrawMoney(address payable _to,uint _amount)external ownerOrAllowed(_amount){
          require(_amount<=address(this).balance, "Contract does not have enough money");

          if(owner()!=msg.sender){
                reduceAllowance(msg.sender,_amount);
          }
          emit MoneySent(_to,_amount);

          _to.transfer(_amount);


      }


      receive() external  payable{
          emit MoneyReceived(msg.sender,msg.value);
      }



       
      
      function renounceOwnership() public view override onlyOwner {
        revert("can't renounceOwnership here"); //not possible with this smart contract
    }



}
