package com.powerwolf.settings;

import com.powerwolf.utils.DateTimeUtil;
import com.powerwolf.utils.MD5Util;
import org.junit.Test;

public class test {
    @Test
    public void test01(){
        String expireTime = "2019-10-10 10:10:10";
        String currentTime = DateTimeUtil.getSysTime();

        String pwd = "123";
        String md5Pwd = MD5Util.getMD5(pwd);
        System.out.println(md5Pwd);
    }
}
