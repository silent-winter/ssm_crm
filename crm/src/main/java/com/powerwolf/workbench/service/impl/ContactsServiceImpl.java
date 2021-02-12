package com.powerwolf.workbench.service.impl;

import com.powerwolf.workbench.dao.ContactsDao;
import com.powerwolf.workbench.dao.ContactsRemarkDao;
import com.powerwolf.workbench.domain.Contacts;
import com.powerwolf.workbench.service.ContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ContactsServiceImpl implements ContactsService {
    @Autowired
    private ContactsDao contactsDao;
    @Autowired
    private ContactsRemarkDao contactsRemarkDao;


    @Override
    public List<Contacts> getContactsList(String name) {
        return contactsDao.getContactsListByName(name);
    }

    @Override
    public List<Contacts> getContactsListByCustomerId(Map<String, String> map) {
        return contactsDao.getContactsListByNameAndCustomerId(map);
    }

    @Override
    public boolean addContacts(Contacts contacts) {
        return contactsDao.addContacts(contacts) == 1;
    }

    @Override
    public void deleteContacts(String[] id) {
        if(contactsDao.deleteContactsByIds(id) != 1){
            throw new RuntimeException("删除联系人失败");
        }

        if(contactsRemarkDao.getTotalByContactsId(id[0]) != contactsRemarkDao.deleteContactsRemarkByContactsId(id[0])){
            throw new RuntimeException("删除联系人备注失败");
        }
    }
}
