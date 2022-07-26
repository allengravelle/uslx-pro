//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "./strutil.sol"; 
import "./IERC20.sol";
 
contract LotteryPool {
    
    address private m_tokenOwner = msg.sender;
    address private my_address  =msg.sender;
     
    mapping(uint256 =>Lottery) private  lotterys;
    mapping (uint256 => mapping (uint256 => LotteryInfo)) private lotteryInfos;
    mapping (uint256 => mapping (uint256 => LotteryResult)) private lRs;
     
    mapping (address => mapping (uint256 => uint256)) internal user_lottery;
    uint256 public lotteryId;
    mapping (uint256 => mapping (uint256 => uint256)) private  wdata;
     
    mapping(uint256 => uint256) private superIds;
    uint256 private superId;

    //
    mapping (address => mapping (uint256 => uint256)) private meLottery;
    mapping (address => uint256) private meLotteryIds;
 
     
    mapping(uint256 =>uint256) private  infoIndexs;
    uint256 hb_untiy = 1; 

    uint256 public sumPeriods;
    uint256 public sumWinners;
    uint256 public totalAmount;
    uint256 public maxAmount;
    address private baseContractAddr;
    address private usdtContractAddr;
    using strutil for *; 
    constructor () {
        m_tokenOwner = msg.sender;
    }



    struct Lottery{

        uint256 lotteryId;
         
        address mz_address;
         
        uint256 sum_num;
         
        uint256 one_money;
         
        uint256 wmode;
         
        uint256 winnum;
         
        uint256 startTime;
         
        uint256 endTime;
         
        uint256 valid;
         
        uint256 now_num;
        string txHash;
    }

    struct LotteryInfo{
        uint256[] wna;
        uint256 lotteryId;
        address u_address;
        uint256 num;
        uint256 cTime;
    }


    struct LotteryResult{
        uint256 wId;
        address u_adr;
        uint256 reward;
        uint256 cTime;
    }

     
    function createPool( uint256 one_money,uint256 wmode) public returns (bool success){

        require(one_money>0 , "CP_OMY");
        require(wmode>0 , "CP_MODE_ERR");
        uint256 startTime = block.timestamp;
        uint256 endTime = 0;
        Lottery storage lottery = lotterys[lotteryId];
        if(wmode == 10){
            require(msg.sender == m_tokenOwner,"CP_NOT_PO");
            Lottery memory msuper = getSuperLotteryVo();
            require(msuper.valid==0,"super_ex");
            if(msg.sender == m_tokenOwner && msuper.valid==0){
                lottery.lotteryId = lotteryId;
                lottery.mz_address = msg.sender;
                lottery.one_money = one_money;
                lottery.wmode = wmode;
                lottery.startTime = startTime;
                lottery.endTime = endTime;
                lottery.valid = 1;
                lottery.now_num = 0;
                lottery.winnum = 20;
                success = true;
                superIds[superId]= lotteryId;
                superId ++;
                emit NewLottery(lotteryId++);

            }
            return true;

        }else{
            uint256 tokens = one_money*hb_untiy;
            require(checkAddressTokens(usdtContractAddr,msg.sender, tokens),"CP_NOT_MO");
        }

        uint8[5] memory  wnums = [1,1,3,10,20];
        uint8[5] memory  snum = [3,5,10,50,100];

        lottery.winnum = wnums[wmode-1];

        lottery.lotteryId = lotteryId;
        lottery.mz_address = msg.sender;
        lottery.one_money = one_money;
        lottery.sum_num = snum[wmode-1];
        lottery.wmode = wmode;
        lottery.startTime = startTime;
        lottery.endTime = endTime;
        lottery.valid = 1;
        lottery.now_num = 0;
        if(wmode!=10){
             
            joinLottery(lotteryId,1);
        }

        emit NewLottery(lotteryId++);
         
        return true;
    }

    function newAddress(address _addr) public{
        require(msg.sender == m_tokenOwner,"N_NOT_PO");
        require(_addr != address(0), "A_E");
        my_address = _addr;
    }

    function strLottery(Lottery memory lot) private pure returns (string memory  nss) {
         
        string memory  ns =  foo(strutil.toString(lot.lotteryId),"");
        string memory _address = strutil.toHexString(uint256(uint160(lot.mz_address)), 20);
        ns = foo(ns,_address);
        string memory one_money = strutil.toString(lot.one_money);
        ns = foo(ns,one_money);
        string memory sum_num = strutil.toString(lot.sum_num);
        ns = foo(ns,sum_num);
        string memory startTime = strutil.toString(lot.startTime);
        ns = foo(ns,startTime);
        string memory endTime = strutil.toString(lot.endTime);
        ns = foo(ns,endTime);
        string memory now_num = strutil.toString(lot.now_num);
        ns = foo(ns,now_num);
        string memory wmode = strutil.toString(lot.wmode);
        ns = foo(ns,wmode);
        string memory winnum = strutil.toString(lot.winnum);
        ns = foo(ns,winnum);
        string memory valid = strutil.toString(lot.valid);
        ns = foo(ns,valid);
        ns = foo(ns,lot.txHash);
        return ns;
    }

    function foo(string memory s1, string memory s2) private pure returns (string memory  nss) {
        string memory fg = ",";
        return fooV2(s1,s2,fg);
    }

    function foo2dl(string memory s1, string memory s2) private pure returns (string memory  nss) {
        string memory fg = "$";
        return fooV2(s1,s2,fg);
    }

    function fooV3(string memory s1, string memory s2) private pure returns (string memory  nss) {
        string memory fg = "##";
        return fooV2(s1,s2,fg);
    }

    function fooV2(string memory s1, string memory s2,string memory fg) private pure returns (string memory  nss) {
        string memory  ns = s1.toSlice().concat(s2.toSlice());
        ns = ns.toSlice().concat(fg.toSlice());
        return ns;
    }

    function getLotterys(uint256 state,uint256 startIndex,uint256 _size) public view returns (bool isend,uint256 lastIndex,string memory lots){

        uint256 index = 0;
        string memory lots = "";
        uint256 lIndex = lotteryId;

        if(startIndex > lotteryId){
            startIndex = lotteryId;
        }

        for(uint256 i = startIndex;i < lotteryId ;i++){
            Lottery memory lot = lotterys[i];
            if(lot.valid == state && lot.wmode!=10){

                lots = fooV3(lots,strLottery(lot));
                index++;
                if(index>=_size) {
                    lIndex = i+1;
                    break;
                }
            }
        }

        isend = (lIndex == lotteryId);
        return (isend,lIndex,lots);
    }

    function getMeLotterys(uint256 state,uint256 startIndex,uint256 _size) public view returns (bool isend,uint256 lastIndex,string memory lots){
        uint256 size =  meLotteryIds[msg.sender];

        uint256 index = 0;
        string memory lots = "";
        uint256 lIndex = size;

        if(startIndex>size){
            startIndex = size;
        }

        for(uint256 i = startIndex;i < size ;i++){
            uint256 cindex = meLottery[msg.sender][i];
            Lottery memory lot = lotterys[cindex];
            if(lot.valid == state && lot.wmode!=10){

                lots = fooV3(lots,strLottery(lot));
                index++;
                if(index>=_size) {
                    lIndex = i+1;
                    break;
                }
            }
        }
        isend = (lIndex == size);
        return (isend,lIndex,lots);
    }



    function getMainData()public view returns(uint256 total,uint256 lId,uint256 maxA,uint256 sumW){
        return (totalAmount,sumPeriods, maxAmount,sumWinners);
    }

    function getSuperLottery() public view returns (string memory lots ){
        Lottery memory lot = getSuperLotteryVo();
        if(lot.valid == 1 && lot.wmode == 10) lots = strLottery(lot);
        return lots;
    }

    function getSuperLotteryVo() private view returns (Lottery memory lots ){
        for(uint256 i=0;i<superId;i++){
            uint256 lid = superIds[i];
            Lottery memory lot = lotterys[lid];
            if(lot.valid == 1 && lot.wmode == 10){
                return lot;
            }
        }

    }

    function strLotteryInfo(LotteryInfo memory lot) private pure returns (string memory  nss) {
        string memory lid = strutil.toString(lot.lotteryId);
        string memory  ns =  foo(lid,"");
        string memory _address = strutil.toHexString(uint256(uint160(lot.u_address)), 20);
        ns = foo(ns,_address);
        string memory num = strutil.toString(lot.num);
        ns = foo(ns,num);
        string memory cTime = strutil.toString(lot.cTime);
        ns = foo(ns,cTime);

        string  memory winn_no = "";
        for(uint256 i = 0 ; i <lot.wna.length;i++){
            string memory linfonum = strutil.toString(lot.wna[i]);
            winn_no = foo2dl(winn_no,linfonum);
        }
        ns = foo(ns,winn_no);
        return ns;
    }

    function getLotteryInfoStr(uint256 lid,uint256 startIndex,uint256 size) public view returns (bool isend, uint256 lastIndex,string memory lois ){
        Lottery memory lottery = lotterys[lid];
         
        string memory lots = "";

        if(startIndex>lottery.now_num){
            startIndex = lottery.now_num;
        }
        lastIndex = lottery.now_num;
        isend = false;
        uint256 ii = 0;
        for(uint256 i = startIndex; i < lottery.now_num;i++){
            LotteryInfo memory lot = lotteryInfos[lid][i];
            if( lot.u_address != address(0)){
                // strlists[i] = strLotteryInfo(lot);
                lots = fooV3(lots,strLotteryInfo(lot));
                ii ++;
                if(ii>=size) {
                    lastIndex = i+1;
                    break;
                }
            }
        }
        isend = (lastIndex == lottery.now_num);
        return (isend,lastIndex,lots);
    }

    function strLotteryResult(LotteryResult memory lot) private pure returns (string memory  nss) {
        string memory lid = strutil.toString(lot.wId);
        string memory  ns =  foo(lid,"");
        string memory _address = strutil.toHexString(uint256(uint160(lot.u_adr)), 20);
        ns = foo(ns,_address);
        string memory reward = strutil.toString(lot.reward);
        ns = foo(ns,reward);
        string memory cTime = strutil.toString(lot.cTime);
        ns = foo(ns,cTime);
        return ns;
    }

    function getLotteryResultStr(uint256 lid,uint256 startIndex,uint256 size) public view returns (bool isend, uint256 lastIndex,string memory lois ){
        Lottery memory lottery = lotterys[lid];
        
        string memory lots = "";
        
        lastIndex = lottery.winnum;
        isend = false;
        if(startIndex>lottery.winnum){
            startIndex = lottery.winnum;
        }

        uint256 ii = 0;
        for(uint256 i = startIndex; i < lottery.winnum;i++){
            LotteryResult memory lot = lRs[lid][i];
            if( lot.u_adr != address(0)){
              
                lots = fooV3(lots,strLotteryResult(lot));
                ii ++;
                if(ii>=size) {
                    lastIndex = i+1;
                    break;
                }
            }
        }
        if(lastIndex == lottery.winnum) isend = true;
        return (isend,lastIndex,lots);
    }





    function joinLottery(uint256 lid,uint num) public  returns (bool){
        bool success = true;
        Lottery storage lottery = lotterys[lid];
        require(lottery.valid == 1, "JL_O");
        //
        uint256 total = lottery.one_money * num * hb_untiy;
        address _owner = m_tokenOwner;
        if(lottery.wmode!=10){
            require(lottery.now_num + num <= lottery.sum_num, "JL_NTM");

            require(checkAddressTokens(usdtContractAddr,msg.sender, total),"JL_NU");

            transferFromMe(_owner,msg.sender,total);

            transferFromUsdt(msg.sender,_owner,total);
        }else{
             
            transferFromMe(msg.sender,_owner,total);
        }

        LotteryInfo storage linfo = lotteryInfos[lid][lottery.now_num];
        linfo.wna = new uint256[](num);
        uint256 index = 0;
        for(uint i = lottery.now_num ; i < num+lottery.now_num ;i++){
            linfo.wna[index] = i;
            index ++;
        }

        uint256 cTime = block.timestamp;

        linfo.lotteryId = lid;
        linfo.u_address = msg.sender;
        linfo.num = num;
        linfo.cTime = cTime;
        lottery.now_num = lottery.now_num + num;

        if(lottery.wmode!=10 && lottery.now_num >= lottery.sum_num){
            lottery.valid = 2;
        }
        bool isadd = true;
        uint256 meids =  meLotteryIds[msg.sender];
        for(uint256 i = 0;i < meids ;i++){
            uint256 cindex = meLottery[msg.sender][i];
            if(cindex == lid){
                isadd = false;
            }
        }
        if(isadd){
            meLottery[msg.sender][meids] = lid;
            meids ++;
            meLotteryIds[msg.sender] = meids;
        }

         
        emit NewUserJoinLottery(lid,0);
        return success;
    }


    event LogUint(string, uint);

    function log(string  memory s , uint x)  internal {
        emit LogUint(s, x);
    }



    function getLotteryInfos(uint256 lid) private view returns (LotteryInfo[] memory loss ){
        Lottery memory lottery = lotterys[lid];
        LotteryInfo[] memory los = new LotteryInfo[](lottery.now_num);

        for(uint256 i = 0; i <lottery.now_num;i++){
            LotteryInfo memory lot = lotteryInfos[lid][i];
            if(lot.u_address != address(0)){
                los[i].lotteryId = lot.lotteryId;
                los[i].u_address = lot.u_address;
                los[i].num = lot.num;
                los[i].cTime = lot.cTime;
                los[i].lotteryId = lot.lotteryId;
                los[i].wna = lot.wna;
            }
        }

        return los;
    }




    function getWinPro(Lottery memory lot,LotteryInfo[] memory lif)  private  {
        uint256 wmode = lot.wmode;
        uint256 lid = lot.lotteryId;

        uint256 stime = 0;
        for(uint256 i = 0; i <lif.length;i++){
            LotteryInfo memory item = lif[i];
            if(item.u_address!=address(0)){
                stime = item.cTime + stime;
            }
        }

        uint256[] memory wrid = getRand(stime,lot.now_num,lot.winnum);

        if(wmode == 3){ 
            uint8[3] memory  rews =[70,10,10];
            for(uint8 i = 0 ;i<rews.length;i++){
                wdata[lid][wrid[i]] = rews[i];
            }
        }else if(wmode == 4){
             
            uint8[10] memory rews =[60,10,5,5,5,1,1,1,1,1];
            for(uint8 i = 0 ;i<rews.length;i++){
                wdata[lid][wrid[i]] = rews[i];
            }
        }else if(wmode == 5||wmode == 10){
             
            uint8[20] memory rews =[54,5,5,5,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1];
            for(uint8 i = 0 ;i<rews.length;i++){
                wdata[lid][wrid[i]] = rews[i];
            }
        }else{
             
            wdata[lid][wrid[0]] = 90;
        }
    }

    function setTxHash(uint256 lid,string memory txHash) public  returns (bool) {
        require(msg.sender == m_tokenOwner, "olno");
        Lottery storage  lottery = lotterys[lid];
        if(lottery.valid == 3){
            lottery.txHash = txHash;
        
        }

        return true;
    }


    function openLottery(uint256 lid) public  returns (bool) {

        require(msg.sender == m_tokenOwner, "olno");
        Lottery storage  lottery = lotterys[lid];

        uint256 sum_pool = lottery.now_num * lottery.one_money * hb_untiy;
        totalAmount = totalAmount + sum_pool;
        address _owner = m_tokenOwner;

        if(lottery.wmode == 10){
            require(lottery.valid == 1 , "olvs");
            require(lottery.now_num >= 50, "olnn");
            sum_pool = lottery.sum_num;
        }else{
            require(lottery.valid == 2 , "olv");
            require(lottery.now_num == lottery.sum_num, "olnw");
            Lottery memory mm = getSuperLotteryVo();
            Lottery storage superlot = lotterys[mm.lotteryId] ;
            if(superlot.valid==1){
                superlot.sum_num =  superlot.sum_num+sum_pool /100;
            }
            transferFromUsdt(_owner,my_address,sum_pool*5/100 );
             
        }

        LotteryInfo[] memory lotteryinfos= getLotteryInfos(lid);

        getWinPro(lottery,lotteryinfos);
 

        transferFromUsdt(_owner,lottery.mz_address,sum_pool*5/100 );

        uint256 inw = 0;

        for(uint256 i = 0; i < lotteryinfos.length;i++){
            LotteryInfo memory item = lotteryinfos[i];
            for(uint256 j = 0; j < item.wna.length;j++){
                 
                uint256 jlbfb = wdata[lid][item.wna[j]];
                if(jlbfb>0){
                    LotteryResult storage lRes = lRs[lid][inw];
                    uint256 total  = sum_pool * jlbfb/100 ;
                    lRes.reward = total/hb_untiy;
                    lRes.wId = item.wna[j];
                    lRes.cTime = block.timestamp;
                    lRes.u_adr = item.u_address;
                     
                    transferFromUsdt(_owner,item.u_address,total);
                    inw ++;
                    sumWinners ++;
                    if(maxAmount<total){
                        maxAmount = total;
                    }
                }
            }
        }
        sumPeriods ++;
        lottery.valid = 3;
        return true;
    }



    event NewUserJoinLottery(uint256 indexed lId,uint256 indexed mid);

    event NewLottery(uint256 indexed lId);



    function setContractAddr(address _contract,address _usdtContract) public returns(bool ){
        require(msg.sender == m_tokenOwner,"sc_err_o");
        baseContractAddr = _contract;
        usdtContractAddr = _usdtContract;
        return true;
    }
 

    function checkAddressTokens(address conteractaddr, address _adress,uint tokens) private view returns(bool){

        require(conteractaddr != address(0) && conteractaddr != address(0), "cat_cc_e");

        IERC20 mToken = IERC20(conteractaddr);  

        require(mToken.balanceOf(_adress) >= tokens,"cat_b_er");

        return true;
    }


    function transferFromMe(address from, address to, uint tokens)  private returns (bool success) {
        return transferFromToken(baseContractAddr,from,to,tokens);
    }

    function transferFromUsdt(address from, address to, uint tokens)  private returns (bool success) {
        return transferFromToken(usdtContractAddr,from,to,tokens);
    }


    function transferFromToken(address contractAdd, address from, address to, uint tokens)  private returns (bool success) {
       
        require(contractAdd != address(0) && contractAdd != address(0), "tfu_cc_e");

        IERC20 mToken = IERC20(contractAdd);
        
        require(mToken.balanceOf(from) >= tokens,"tfu_b_er");
         
        require(mToken.transferFrom(from,to,tokens),"tfu_ttf");

        return true;
    }



    function getRand(uint256 rxyz,uint256 _length,uint256 snum) public  returns (uint256[] memory wids){
        uint256[] memory  wid = new uint256[](snum);
        for(uint256 i = 0; i < snum;i++){
            uint256 _rand = rand(rxyz,_length);
            while(isenu(wid,_rand)){
                _rand = rand(rxyz,_length);
            }
            wid[i] = _rand;
        }
        return wid;
    }

    function isenu(uint256[] memory llnum ,uint256 newnum) private pure returns(bool){
        for(uint256 i = 0; i < llnum.length;i++){
            if(llnum[i] == newnum){
                return true;
            }
        }
        return false;
    }


    function rand(uint256 randnum, uint256 _length) public  returns(uint256) {
        uint256 gas = gasleft();
    
        bytes memory bb = abi.encodePacked(block.difficulty,randnum,gas,block.timestamp);
        bytes32 b32 = keccak256(bb);
        uint256 rando = uint256(b32)/block.timestamp;
        uint256 rets = rando%_length;
        return rets;
    }

}