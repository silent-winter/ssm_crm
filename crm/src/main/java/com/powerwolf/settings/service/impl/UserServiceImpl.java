package com.powerwolf.settings.service.impl;

import com.powerwolf.exception.LoginException;
import com.powerwolf.settings.dao.UserDao;
import com.powerwolf.settings.domain.User;
import com.powerwolf.settings.service.UserService;
import com.powerwolf.utils.DateTimeUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserDao userDao;

    @Override
    public User login(String loginAct, String loginPwd, String ip) throws LoginException {
        Map<String, String> mp = new HashMap<>();
        mp.put("loginAct", loginAct);
        mp.put("loginPwd", loginPwd);

        User user = userDao.login(mp);

        if(user == null){
            //没有查询到结果
            throw new LoginException("账号或密码错误");
        }

        //账号密码正确，继续验证
        //验证失效事件
        String expireTime = user.getExpireTime();
        String currentTime = DateTimeUtil.getSysTime();
        if(expireTime.compareTo(currentTime) < 0){
            throw new LoginException("账号已失效");
        }

        //验证锁定状态
        String lockState = user.getLockState();
        if("0".equals(lockState)){
            throw new LoginException("账号已锁定");
        }

        //验证ip地址
        String allowIps = user.getAllowIps();
        if(!allowIps.contains(ip)){
            throw new LoginException("ip地址受限");
        }

        return user;
    }

    @Override
    public List<User> getUserList() {
        return userDao.getUserList();
    }
}
