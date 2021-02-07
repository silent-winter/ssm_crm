package com.powerwolf.workbench.web.controller;

import com.powerwolf.settings.domain.User;
import com.powerwolf.settings.service.UserService;
import com.powerwolf.utils.DateTimeUtil;
import com.powerwolf.utils.UUIDUtil;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Activity;
import com.powerwolf.workbench.domain.Contacts;
import com.powerwolf.workbench.domain.Tran;
import com.powerwolf.workbench.domain.TranHistory;
import com.powerwolf.workbench.service.ActivityService;
import com.powerwolf.workbench.service.ContactsService;
import com.powerwolf.workbench.service.CustomerService;
import com.powerwolf.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/workbench/transaction")
public class TranController {
    @Autowired
    private TranService tranService;
    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private CustomerService customerService;


    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVO<Tran> pageList(@RequestParam("pageNo") String strPageNo, @RequestParam("pageSize") String strPageSize, Tran tran){
        int pageNo = Integer.parseInt(strPageNo);
        int pageSize = Integer.parseInt(strPageSize);
        //跳过的记录数
        int skipCount = (pageNo - 1) * pageSize;

        Map<String, Object> map = new HashMap<>();
        map.put("skipCount", skipCount);
        map.put("pageSize", pageSize);

        return tranService.pageList(map);
    }


    @RequestMapping("/createTran.do")
    public ModelAndView createTran(HttpSession session){
        //获取用户列表和当前登录用户
        List<User> userList = userService.getUserList();
        User user = (User) session.getAttribute("user");

        //转发
        ModelAndView mv = new ModelAndView();
        mv.addObject("userList", userList);
        mv.addObject("user", user);
        mv.setViewName("/workbench/transaction/save.jsp");
        return mv;
    }


    @RequestMapping("/searchActivity.do")
    @ResponseBody
    public List<Activity> getActivityList(String name){
        return activityService.getActivityListByName(name);
    }


    @RequestMapping("/searchContacts.do")
    @ResponseBody
    public List<Contacts> getContactsList(String name){
        return contactsService.getContactsList(name);
    }


    @RequestMapping("/getCustomerName.do")
    @ResponseBody
    public List<String> getCustomerName(String name){
        return customerService.getCustomerNameList(name);
    }


    @RequestMapping("/saveTran.do")
    public ModelAndView saveTran(Tran tran, String customerName, HttpSession session){
        ModelAndView mv = new ModelAndView();
        mv.setViewName("redirect:/workbench/transaction/index.jsp");

        tran.setCreateBy(((User) session.getAttribute("user")).getName());
        tran.setCreateTime(DateTimeUtil.getSysTime());
        tran.setId(UUIDUtil.getUUID());

        try {
            tranService.addTran(tran, customerName);
            mv.addObject("success", true);
        } catch (Exception e){
            e.printStackTrace();
            mv.addObject("success", false);
        }
        return mv;
    }

    @RequestMapping("/detail.do")
    public ModelAndView toDetail(String id, HttpServletRequest request){
        ModelAndView mv = new ModelAndView();
        mv.setViewName("/workbench/transaction/detail.jsp");

        Tran tran = tranService.getDetail(id);
        mv.addObject("tran", tran);

        String stage = tran.getStage();
        Map<String, String> map = (Map<String, String>) request.getServletContext().getAttribute("possibility");
        mv.addObject("possibility", map.get(stage));

        return mv;
    }

    @RequestMapping("/getTranHistoryList.do")
    @ResponseBody
    public List<TranHistory> getTranHistoryList(String tranId, HttpServletRequest request){
        List<TranHistory> tranHistoryList = tranService.getTranHistoryList(tranId);
        Map<String, String> map = (Map<String, String>) request.getServletContext().getAttribute("possibility");

        for(TranHistory tranHistory : tranHistoryList){
            //根据每一条交易历史设置其可能性
            String stage = tranHistory.getStage();
            tranHistory.setPossibility(map.get(stage));
        }

        return tranHistoryList;
    }


    @RequestMapping("/changeStage.do")
    @ResponseBody
    public Map<String, Object> changeStage(Tran tran, HttpServletRequest request, HttpSession session){
        Map<String, String> pMap = (Map<String, String>) request.getServletContext().getAttribute("possibility");
        String possibility = pMap.get(tran.getStage());

        tran.setEditTime(DateTimeUtil.getSysTime());
        tran.setEditBy(((User) session.getAttribute("user")).getName());

        Map<String, Object> map = new HashMap<>();
        map.put("tran", tran);
        map.put("possibility", possibility);

        try {
            tranService.changeStage(tran);
            map.put("success", true);
        } catch (Exception e){
            e.printStackTrace();
            map.put("success", false);
        }
        return map;
    }

    @RequestMapping("/getCharts.do")
    @ResponseBody
    public PaginationVO<Map<String, Object>> getCharts(){
        return tranService.getCharts();
    }
}
