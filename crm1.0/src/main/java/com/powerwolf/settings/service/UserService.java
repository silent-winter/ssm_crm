package com.powerwolf.settings.service;

import com.powerwolf.exception.LoginException;
import com.powerwolf.settings.domain.User;

import java.util.List;

public interface UserService {
    User login(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> getUserList();
}
