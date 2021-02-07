package com.powerwolf.web.filter;

import com.powerwolf.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;

        String path = request.getServletPath();
        //不应该拦截的资源
        if("/login.jsp".equals(path) || "/user/login.do".equals(path)){
            chain.doFilter(req, resp);
            return;
        }

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if(user != null){
            //表示用户已经登录，放行
            chain.doFilter(req, resp);
        }else{
            //用户没有登录，重定向到登录界面
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    public void destroy() {

    }
}
