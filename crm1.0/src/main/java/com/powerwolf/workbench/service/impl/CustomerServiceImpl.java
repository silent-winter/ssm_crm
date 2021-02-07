package com.powerwolf.workbench.service.impl;

import com.powerwolf.workbench.dao.CustomerDao;
import com.powerwolf.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerServiceImpl implements CustomerService {
    @Autowired
    private CustomerDao customerDao;

    @Override
    public List<String> getCustomerNameList(String name) {
        return customerDao.getNameListByCustomerName(name);
    }
}
