package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsDao {
    //添加联系人
    int addContacts(Contacts contacts);

    //根据联系人名称查询联系人
    List<Contacts> getContactsListByName(String name);

    //根据联系人名称和客户名称查询联系人
    List<Contacts> getContactsListByNameAndCustomerId(Map<String, String> map);

    //根据联系人id数组删除联系人
    int deleteContactsByIds(String[] id);
}
