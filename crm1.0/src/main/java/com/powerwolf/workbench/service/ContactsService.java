package com.powerwolf.workbench.service;

import com.powerwolf.workbench.domain.Contacts;

import java.util.List;

public interface ContactsService {
    //根据联系人名称获取联系人列表
    List<Contacts> getContactsList(String name);
}
