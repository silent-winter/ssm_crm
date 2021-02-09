package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerDao {
    //根据客户名称精确查询
    Customer getCustomerByName(String name);

    //添加客户
    int addCustomer(Customer customer);

    //根据客户名称查询相关的客户名称列表
    List<String> getNameListByCustomerName(String name);

    //根据条件查询客户总数
    int getTotalByCondition(Map<String, Object> map);

    //根据条件查询出所有客户列表
    List<Customer> getCustomerListByCondition(Map<String, Object> map);

    //根据id查询客户
    Customer getCustomerById(String id);

    //更新客户信息
    int updateCustomer(Customer customer);

    //根据客户id数组删除所有客户
    int deleteCustomerByIds(String[] ids);

    //根据id查询客户，owner字段转换为名字
    Customer getCustomerInfoById(String id);
}
