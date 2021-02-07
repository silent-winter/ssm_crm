package com.powerwolf.web.listener;

import com.powerwolf.settings.domain.DicValue;
import com.powerwolf.settings.service.DicService;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

public class SysInitListener implements ServletContextListener {
    /*
        服务器启动，上下文域对象创建，执行该方法
        servletContextEvent：该参数能够取得监听的对象
     */
    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        //获得上下文域对象
        ServletContext application = servletContextEvent.getServletContext();

        ApplicationContext ac = WebApplicationContextUtils.getWebApplicationContext(application);
        assert ac != null;
        DicService dicService = (DicService) ac.getBean("dicService");

        //取数据字典
        Map<String, List<DicValue>> map = dicService.getKeyMapperList();

        for(String key : map.keySet()){
            application.setAttribute(key, map.get(key));
        }


        //处理stage2Possibility文件
        Map<String, String> pMap = new HashMap<>();
        ResourceBundle rb = ResourceBundle.getBundle("stage2Possibility");
        Enumeration<String> e = rb.getKeys();
        while(e.hasMoreElements()){
            //阶段
            String key = e.nextElement();
            //可能性
            String value = rb.getString(key);
            pMap.put(key, value);
        }

        application.setAttribute("possibility", pMap);
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {

    }
}
