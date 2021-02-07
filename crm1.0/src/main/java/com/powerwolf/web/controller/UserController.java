package com.powerwolf.web.controller;

import com.powerwolf.exception.LoginException;
import com.powerwolf.settings.domain.User;
import com.powerwolf.settings.service.UserService;
import com.powerwolf.utils.MD5Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;

    //用户登录
    @RequestMapping(value = "/login.do")
    @ResponseBody
    public Map<String, Object> login(HttpServletRequest request, HttpSession session, String loginAct, String loginPwd){
        //转为md5密文形式
        loginPwd = MD5Util.getMD5(loginPwd);
        //接受浏览器端的ip地址
        String ip = request.getRemoteAddr();
        Map<String, Object> map = new HashMap<>();

        try {
            User user = userService.login(loginAct, loginPwd, ip);

            //执行到此处，表示登录成功
            session.setAttribute("user", user);
            map.put("success", true);

            return map;

        } catch (LoginException e) {
            e.printStackTrace();
            //登录失败，获取失败提示信息
            String error = e.getMessage();
            map.put("success", false);
            map.put("msg", error);

            return map;
        }
    }
}
