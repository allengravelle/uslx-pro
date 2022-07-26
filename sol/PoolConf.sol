//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "./strutil.sol";
import "./IERC20.sol";

contract PoolConf  {

    address private m_tokenOwner = msg.sender;
    address private baseContractAddr;
    address private baseUsdtContractAddr;
    address private baseJLYXContractAddr;
    address private baseConfContractAddr;
    string  private chain;
    string  private socialUrl;
    string  private telegram;
    string  private twitter;
    string  private facebook;

    uint constant internal SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant internal SECONDS_PER_HOUR = 60 * 60;
    uint constant internal SECONDS_PER_MINUTE = 60;
    uint constant internal OFFSET19700101 = 2440588;
    uint16 constant ORIGIN_YEAR = 1970;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant DAY_IN_SECONDS = 86400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    using strutil for *;
    uint256 hb_untiy = 1;

    mapping (address =>mapping(uint256 =>mapping (string => uint256)) ) internal taskDay;

    mapping (uint256 => uint256) internal taskToken;


    constructor () {
        m_tokenOwner = msg.sender;
    }

    function getConf() public view returns (string memory config){
        return strConfig();
    }


    function foo(string memory s1, string memory s2) private pure returns (string memory  nss) {
        string memory fg = ",";
        return fooV2(s1,s2,fg);
    }

    function foo2dl(string memory s1, string memory s2) private pure returns (string memory  nss) {
        string memory fg = "$";
        return fooV2(s1,s2,fg);
    }

    function fooV2(string memory s1, string memory s2,string memory fg) private pure returns (string memory  nss) {
        string memory  ns = s1.toSlice().concat(s2.toSlice());
        ns = ns.toSlice().concat(fg.toSlice());
        return ns;
    }

    function setTask(uint[] memory taskNum) public returns(bool success){
        require(msg.sender == m_tokenOwner,"N_PO");

        for(uint i = 0; i <taskNum.length;i++){
            taskToken[i] = taskNum[i];
        }
    }

    function postTask(uint tid) public returns (bool success){
        require(tid>0 ,"TI_E");
        string memory datestr = _daysToDate(block.timestamp);
        uint256 ii =  taskDay[msg.sender][tid][datestr];
        if(ii==0){
            taskDay[msg.sender][tid][datestr]  = taskToken[tid];
            transferFromMe(m_tokenOwner, msg.sender, taskToken[tid]*hb_untiy);
        }
    }

    function transferFromMe(address from, address to, uint tokens)  private returns (bool success) {
        return transferFromToken(baseJLYXContractAddr,from,to,tokens);
    }




    function transferFromToken(address contractAdd, address from, address to, uint tokens)  private returns (bool success) {
        
        require(contractAdd != address(0) && contractAdd != address(0), "tfu_cc_e");

        IERC20 mToken = IERC20(contractAdd);
         
        require(mToken.balanceOf(from) >= tokens,"tfu_b_er");
        
        require(mToken.transferFrom(from,to,tokens),"tfu_ttf");

        return true;
    }

    function _daysToDate(uint timestamp) private pure returns (string memory datestr) {
        uint _days = uint(timestamp) / SECONDS_PER_DAY;
        uint year; uint month; uint day;
        uint L = _days + 68569 + OFFSET19700101;
        uint N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * year / 4 + 31;
        month = 80 * L / 2447;
        day = L - 2447 * month / 80;
        L = month / 11;
        month = month + 2 - 12 * L;
        year = 100 * (N - 49) + year + L;

        string memory  ns =  foo(strutil.toHexString(year),strutil.toHexString(month));
        string memory dayS = strutil.toHexString(day);
        datestr = foo(ns,dayS);
    }



    function strConfig() private view returns (string memory  nss) {
        string memory  ns =  foo(strutil.toHexString(uint256(uint160(baseUsdtContractAddr)), 20),"");
        string memory _address = strutil.toHexString(uint256(uint160(baseContractAddr)), 20);
        ns = foo(ns,_address);
        ns = foo(ns,chain);
        string memory _conf_address = strutil.toHexString(uint256(uint160(baseConfContractAddr)), 20);
        ns = foo(ns,_conf_address);
        ns = foo(ns,socialUrl);
        ns = foo(ns,telegram);
        ns = foo(ns,twitter);
        ns = foo(ns,facebook);
        string memory _jlyxAddress = strutil.toHexString(uint256(uint160(baseJLYXContractAddr)), 20);
        ns = foo(ns,_jlyxAddress);
        return ns;
    }


    function setConf(address _contract, address _usdtcontract,string memory _chain,address _confcontract,address _baseJLYXContractAddr) public  returns(bool ){
        require(msg.sender == m_tokenOwner,"sc_o");
        baseContractAddr = _contract;
        baseUsdtContractAddr = _usdtcontract;
        chain = _chain;
        baseConfContractAddr = _confcontract;
        baseJLYXContractAddr = _baseJLYXContractAddr;
        return true;
    }


    function setOtherConf(string memory _socialUrl,string memory _telegram,string memory _twitter,string memory _facebook) public returns (bool){
        require(msg.sender == m_tokenOwner,"sc_o");
        socialUrl = _socialUrl;
        telegram = _telegram;
        twitter = _twitter;
        facebook = _facebook;
        return true;
    }

}