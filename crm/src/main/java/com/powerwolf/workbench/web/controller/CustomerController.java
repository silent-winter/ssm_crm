package com.powerwolf.workbench.web.controller;

import com.powerwolf.settings.domain.User;
import com.powerwolf.settings.service.UserService;
import com.powerwolf.utils.DateTimeUtil;
import com.powerwolf.utils.UUIDUtil;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Customer;
import com.powerwolf.workbench.domain.CustomerRemark;
import com.powerwolf.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/workbench/customer")
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @Autowired
    private UserService userService;


    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVO<Customer> pageList(@RequestParam("pageNo") String strPageNo, @RequestParam("pageSize") String strPageSize, Customer customer){
        int pageNo = Integer.parseInt(strPageNo);
        int pageSize = Integer.parseInt(strPageSize);
        //跳过的记录数
        int skipCount = (pageNo - 1) * pageSize;

        Map<String, Object> map = new HashMap<>();
        map.put("pageSize", pageSize);
        map.put("skipCount", skipCount);
        map.put("name", customer.getName());
        map.put("owner", customer.getOwner());
        map.put("phone", customer.getPhone());
        map.put("website", customer.getWebsite());

        return customerService.pageList(map);
    }

    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        return userService.getUserList();
    }

    @RequestMapping("/addCustomer.do")
    @ResponseBody
    public Map<String, Boolean> addCustomer(Customer customer, HttpSession session){
        customer.setId(UUIDUtil.getUUID());
        customer.setCreateBy(((User) session.getAttribute("user")).getName());
        customer.setCreateTime(DateTimeUtil.getSysTime());

        Map<String, Boolean> map = new HashMap<>();
        map.put("success", customerService.addCustomer(customer));
        return map;
    }

    @RequestMapping("/getCustomerInfo.do")
    @ResponseBody
    public Map<String, Object> getCustomerInfo(String id){
        //获取用户列表
        List<User> userList = userService.getUserList();
        //获取客户信息
        Customer customer = customerService.getCustomerInfo(id);

        Map<String, Object> map = new HashMap<>();
        map.put("userList", userList);
        map.put("customer", customer);
        return map;
    }

    @RequestMapping("/editCustomer.do")
    @ResponseBody
    public Map<String, Boolean> editCustomer(Customer customer, HttpSession session){
        customer.setEditBy(((User) session.getAttribute("user")).getName());
        customer.setEditTime(DateTimeUtil.getSysTime());

        Map<String, Boolean> map = new HashMap<>();
        map.put("success", customerService.editCustomer(customer));
        return map;
    }

    @RequestMapping("/deleteCustomer.do")
    @ResponseBody
    public Map<String, Boolean> deleteCustomer(@RequestParam("id") String[] ids){
        Map<String, Boolean> map = new HashMap<>();
        try {
            customerService.deleteCustomer(ids);
            map.put("success", true);
        } catch (Exception e){
            e.printStackTrace();
            map.put("success", false);
        }
        return map;
    }

    @RequestMapping("/detail.do")
    public ModelAndView toDetail(String id){
        ModelAndView mv = new ModelAndView();
        mv.setViewName("/workbench/customer/detail.jsp");
        mv.addObject("customer", customerService.detail(id));
        return mv;
    }

    @RequestMapping("/getRemarkList.do")
    @ResponseBody
    public List<CustomerRemark> getCustomerRemarkList(String customerId){
        return customerService.getCustomerRemarkList(customerId);
    }

    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public Map<String, Boolean> deleteRemark(String id){
        Map<String, Boolean> map = new HashMap<>();
        map.put("success", customerService.deleteCustomerRemarkById(id));
        return map;
    }

    @RequestMapping("/editRemark.do")
    @ResponseBody
    public Map<String, Object> editRemark(CustomerRemark customerRemark, HttpSession session){
        customerRemark.setEditTime(DateTimeUtil.getSysTime());
        customerRemark.setEditBy(((User) session.getAttribute("user")).getName());
        customerRemark.setEditFlag("1");
        return customerService.editCustomerRemark(customerRemark);
    }

    @RequestMapping("/addRemark.do")
    @ResponseBody
    public Map<String, Object> addRemark(CustomerRemark customerRemark, HttpSession session){
        System.out.println(customerRemark.getNoteContent());
        customerRemark.setId(UUIDUtil.getUUID());
        customerRemark.setCreateTime(DateTimeUtil.getSysTime());
        customerRemark.setCreateBy(((User) session.getAttribute("user")).getName());
        customerRemark.setEditFlag("0");
        return customerService.addCustomerRemark(customerRemark);
    }
}
