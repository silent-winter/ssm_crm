package com.powerwolf.workbench.service;

import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Customer;
import com.powerwolf.workbench.domain.CustomerRemark;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    //根据客户名称查询客户名称列表，自动补全
    List<String> getCustomerNameList(String name);

    PaginationVO<Customer> pageList(Map<String, Object> map);

    //添加一条客户
    boolean addCustomer(Customer customer);

    //根据id获取该客户的信息
    Customer getCustomerInfo(String id);

    //修改客户信息
    boolean editCustomer(Customer customer);

    //删除客户
    void deleteCustomer(String[] ids);

    //跳转到详细信息页
    Customer detail(String id);

    //根据id获取客户备注列表
    List<CustomerRemark> getCustomerRemarkList(String customerId);

    //根据客户备注id删除备注
    boolean deleteCustomerRemarkById(String id);

    //修改客户备注信息
    Map<String, Object> editCustomerRemark(CustomerRemark customerRemark);

    //添加客户备注
    Map<String, Object> addCustomerRemark(CustomerRemark customerRemark);
}
