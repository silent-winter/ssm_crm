package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.ContactsRemark;

public interface ContactsRemarkDao {
    //添加一条联系人备注
    int addContactsRemark(ContactsRemark contactsRemark);

    //删除联系人备注
    int deleteContactsRemarkByContactsId(String contactsId);

    //根据联系人id查询备注条数
    int getTotalByContactsId(String contactsId);
}
