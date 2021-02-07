package com.powerwolf.workbench.service.impl;

import com.powerwolf.workbench.dao.ContactsDao;
import com.powerwolf.workbench.domain.Contacts;
import com.powerwolf.workbench.service.ContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ContactsServiceImpl implements ContactsService {
    @Autowired
    private ContactsDao contactsDao;


    @Override
    public List<Contacts> getContactsList(String name) {
        return contactsDao.getContactsListByName(name);
    }
}
