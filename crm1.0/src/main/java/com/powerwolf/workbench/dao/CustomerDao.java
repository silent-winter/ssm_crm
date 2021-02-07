package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {
    //根据客户名称精确查询
    Customer getCustomerByName(String name);

    //添加客户
    int addCustomer(Customer customer);

    //根据客户名称查询相关的客户名称列表
    List<String> getNameListByCustomerName(String name);
}
