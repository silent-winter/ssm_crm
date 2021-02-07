package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.ContactsActivityRelation;

public interface ContactsActivityRelationDao {
    //添加联系人和市场活动的关联关系
    int addRelation(ContactsActivityRelation contactsActivityRelation);
}
