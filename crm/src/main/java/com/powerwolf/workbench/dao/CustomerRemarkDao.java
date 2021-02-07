package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.CustomerRemark;

public interface CustomerRemarkDao {
    //添加一条客户备注
    int addCustomerRemark(CustomerRemark customerRemark);
}
