package com.powerwolf.settings.dao;

import com.powerwolf.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserDao {
    User login(Map<String, String> mp);

    List<User> getUserList();
}