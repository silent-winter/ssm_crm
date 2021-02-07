package com.powerwolf.workbench.service.impl;

import com.powerwolf.utils.DateTimeUtil;
import com.powerwolf.utils.UUIDUtil;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.dao.CustomerDao;
import com.powerwolf.workbench.dao.TranDao;
import com.powerwolf.workbench.dao.TranHistoryDao;
import com.powerwolf.workbench.domain.Customer;
import com.powerwolf.workbench.domain.Tran;
import com.powerwolf.workbench.domain.TranHistory;
import com.powerwolf.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class TranServiceImpl implements TranService {
    @Autowired
    private TranDao tranDao;
    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;


    @Override
    public PaginationVO<Tran> pageList(Map<String, Object> map){
        int total = tranDao.getTotalByCondition(map);
        List<Tran> tranList = tranDao.pageList(map);

        PaginationVO<Tran> vo = new PaginationVO<>();
        vo.setTotal(total);
        vo.setDataList(tranList);
        return vo;
    }

    @Override
    @Transactional
    public void addTran(Tran tran, String customerName) {
        //1.判断customerName在客户表中是否存在，如果没有则新建一条客户信息
        Customer customer = customerDao.getCustomerByName(customerName);
        if(customer == null){
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setCreateTime(tran.getCreateTime());
            customer.setCreateBy(tran.getCreateBy());
            customer.setNextContactTime(tran.getNextContactTime());
            customer.setContactSummary(tran.getContactSummary());
            customer.setOwner(tran.getOwner());
            if(customerDao.addCustomer(customer) != 1){
                throw new RuntimeException("添加客户失败");
            }
        }

        //2.添加交易
        //取客户id，封装到tran中
        tran.setCustomerId(customer.getId());
        if(tranDao.addTran(tran) != 1){
            throw new RuntimeException("添加交易失败");
        }

        //3.新建交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setCreateBy(tran.getCreateBy());
        tranHistory.setCreateTime(tran.getCreateTime());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setStage(tran.getStage());
        tranHistory.setTranId(tran.getId());
        if(tranHistoryDao.addTranHistory(tranHistory) != 1){
            throw new RuntimeException("添加交易历史失败");
        }
    }

    @Override
    public Tran getDetail(String id) {
        return tranDao.getTranById(id);
    }

    @Override
    public List<TranHistory> getTranHistoryList(String tranId) {
        return tranHistoryDao.getTranHistoryListByTranId(tranId);
    }

    @Override
    @Transactional
    public void changeStage(Tran tran) {
        //1.改变交易阶段
        if(tranDao.updateTran(tran) != 1){
            throw new RuntimeException("改变交易阶段失败");
        }

        //2.新增交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setCreateBy(tran.getEditBy());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setStage(tran.getStage());
        tranHistory.setTranId(tran.getId());
        if(tranHistoryDao.addTranHistory(tranHistory) != 1){
            throw new RuntimeException("添加交易历史失败");
        }
    }

    @Override
    public PaginationVO<Map<String, Object>> getCharts() {
        int total = tranDao.getTotalByCondition(null);
        List<Map<String, Object>> dataList = tranDao.getCountGroupByStage();

        PaginationVO<Map<String, Object>> vo = new PaginationVO<>();
        vo.setTotal(total);
        vo.setDataList(dataList);

        return vo;
    }
}
