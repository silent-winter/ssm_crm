package com.powerwolf.workbench.service.impl;

import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.dao.CustomerDao;
import com.powerwolf.workbench.dao.CustomerRemarkDao;
import com.powerwolf.workbench.domain.Customer;
import com.powerwolf.workbench.domain.CustomerRemark;
import com.powerwolf.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CustomerServiceImpl implements CustomerService {
    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private CustomerRemarkDao customerRemarkDao;


    @Override
    public List<String> getCustomerNameList(String name) {
        return customerDao.getNameListByCustomerName(name);
    }

    @Override
    public PaginationVO<Customer> pageList(Map<String, Object> map) {
        //查询总记录数
        int total = customerDao.getTotalByCondition(map);

        //查询客户列表
        List<Customer> customerList = customerDao.getCustomerListByCondition(map);

        PaginationVO<Customer> vo = new PaginationVO<>();
        vo.setTotal(total);
        vo.setDataList(customerList);

        return vo;
    }

    @Override
    public boolean addCustomer(Customer customer) {
        return customerDao.addCustomer(customer) == 1;
    }

    @Override
    public Customer getCustomerInfo(String id) {
        return customerDao.getCustomerById(id);
    }

    @Override
    public boolean editCustomer(Customer customer) {
        return customerDao.updateCustomer(customer) == 1;
    }

    @Override
    @Transactional
    public void deleteCustomer(String[] ids) throws RuntimeException {
        //查询出需要删除的客户的备注总条数
        int count1 = customerRemarkDao.getTotalRemarkByIds(ids);
        //删除所有备注
        int count2 = customerRemarkDao.deleteRemarkByIds(ids);
        if(count1 != count2){
            throw new RuntimeException("删除客户备注失败");
        }

        //删除所有客户
        int count3 = customerDao.deleteCustomerByIds(ids);
        if(count3 != ids.length){
            throw new RuntimeException("删除客户失败");
        }
    }

    @Override
    public Customer detail(String id) {
        return customerDao.getCustomerInfoById(id);
    }

    @Override
    public List<CustomerRemark> getCustomerRemarkList(String customerId) {
        List<CustomerRemark> customerRemarkList = customerRemarkDao.getRemarkListByCustomerId(customerId);
        Collections.sort(customerRemarkList);
        return customerRemarkList;
    }

    @Override
    public boolean deleteCustomerRemarkById(String id) {
        return customerRemarkDao.deleteRemarkById(id) == 1;
    }

    @Override
    public Map<String, Object> editCustomerRemark(CustomerRemark customerRemark) {
        Map<String, Object> map = new HashMap<>();
        map.put("success", customerRemarkDao.editRemark(customerRemark) == 1);
        map.put("remark", customerRemarkDao.getCustomerRemarkById(customerRemark.getId()));
        return map;
    }

    @Override
    public Map<String, Object> addCustomerRemark(CustomerRemark customerRemark) {
        Map<String, Object> map = new HashMap<>();
        map.put("success", customerRemarkDao.addCustomerRemark(customerRemark) == 1);
        map.put("remark", customerRemarkDao.getCustomerRemarkById(customerRemark.getId()));
        return map;
    }
}
