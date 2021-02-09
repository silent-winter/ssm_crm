package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.CustomerRemark;

import java.util.List;

public interface CustomerRemarkDao {
    //添加一条客户备注
    int addCustomerRemark(CustomerRemark customerRemark);

    //根据客户id数组查询客户备注的总条数
    int getTotalRemarkByIds(String[] ids);

    //根据客户id数组删除所有相关的客户备注
    int deleteRemarkByIds(String[] ids);

    //根据客户id查询所有备注
    List<CustomerRemark> getRemarkListByCustomerId(String customerId);

    //根据客户备注id删除备注
    int deleteRemarkById(String id);

    //修改备注
    int editRemark(CustomerRemark customerRemark);

    //根据id查询备注
    CustomerRemark getCustomerRemarkById(String id);
}
