package com.powerwolf.workbench.service;

import com.powerwolf.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsService {
    //根据联系人名称获取联系人列表
    List<Contacts> getContactsList(String name);

    //根据联系人名字和客户名字获取客户相关的联系人列表
    List<Contacts> getContactsListByCustomerId(Map<String, String> map);

    //添加一条联系人
    boolean addContacts(Contacts contacts);

    //删除联系人
    void deleteContacts(String[] id);
}
