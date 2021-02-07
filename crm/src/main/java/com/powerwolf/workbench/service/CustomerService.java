package com.powerwolf.workbench.service;

import java.util.List;

public interface CustomerService {
    //根据客户名称查询客户名称列表，自动补全
    List<String> getCustomerNameList(String name);
}
