package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.Contacts;

import java.util.List;

public interface ContactsDao {
    //添加联系人
    int addContacts(Contacts contacts);

    //根据联系人名称查询联系人
    List<Contacts> getContactsListByName(String name);
}
