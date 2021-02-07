package com.powerwolf.workbench.web.controller;

import com.powerwolf.settings.domain.User;
import com.powerwolf.settings.service.UserService;
import com.powerwolf.utils.DateTimeUtil;
import com.powerwolf.utils.UUIDUtil;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Activity;
import com.powerwolf.workbench.domain.Clue;
import com.powerwolf.workbench.domain.Tran;
import com.powerwolf.workbench.service.ActivityService;
import com.powerwolf.workbench.service.ClueService;
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
@RequestMapping("/workbench/clue")
public class ClueController {
    @Autowired
    private ClueService clueService;
    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;


    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        return userService.getUserList();
    }


    @RequestMapping("/saveClue.do")
    @ResponseBody
    public Map<String, Boolean> createClue(Clue clue, HttpSession session){
        String id = UUIDUtil.getUUID();
        //创建时间：当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //创建人：当前登录用户
        String createBy = ((User) session.getAttribute("user")).getName();

        clue.setId(id);
        clue.setCreateTime(createTime);
        clue.setCreateBy(createBy);

        Map<String, Boolean> map = new HashMap<>();
        map.put("success", clueService.createClue(clue));

        return map;
    }


    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVO<Clue> pageList(@RequestParam("pageNo") String strPageNo, @RequestParam("pageSize") String strPageSize, String name, Clue clue){
        int pageNo = Integer.parseInt(strPageNo);
        int pageSize = Integer.parseInt(strPageSize);
        //跳过的记录数
        int skipCount = (pageNo - 1) * pageSize;

        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", clue.getOwner());
        map.put("company", clue.getCompany());
        map.put("phone", clue.getPhone());
        map.put("source", clue.getSource());
        map.put("mphone", clue.getMphone());
        map.put("state", clue.getState());
        map.put("skipCount", skipCount);
        map.put("pageSize", pageSize);

        return clueService.pageList(map);
    }


    @RequestMapping("/detail.do")
    public ModelAndView toDetail(String id){
        Clue clue = clueService.getDetail(id);

        ModelAndView mv = new ModelAndView();
        mv.addObject("clue", clue);
        mv.setViewName("/workbench/clue/detail.jsp");

        return mv;
    }


    @RequestMapping("/getActivityList.do")
    @ResponseBody
    public List<Activity> getActivityList(String clueId){
        return activityService.getRelatedActivityListByClueId(clueId);
    }


    @RequestMapping("/unbound.do")
    @ResponseBody
    public Map<String, Object> unbound(String relationId){
        Map<String, Object> map = new HashMap<>();
        map.put("success", clueService.unbound(relationId));

        return map;
    }


    @RequestMapping("/getActivityListByName.do")
    @ResponseBody
    public List<Activity> getActivityListByName(String name, String clueId){
        Map<String, String> map = new HashMap<>();
        map.put("name", name);
        map.put("clueId", clueId);

        return activityService.getUnrelatedActivityListByName(map);
    }


    @RequestMapping("/bound.do")
    @ResponseBody
    public Map<String, Boolean> bound(String clueId, String[] activityId){
        Map<String, Boolean> map = new HashMap<>();

        try {
            clueService.bound(clueId, activityId);
        } catch (Exception e) {
            e.printStackTrace();
            map.put("success", false);
            return map;
        }

        map.put("success", true);
        return map;
    }


    @RequestMapping("/getConvertActivity.do")
    @ResponseBody
    public List<Activity> getConvertActivityByName(String name){
        return activityService.getActivityListByName(name);
    }


    @RequestMapping("/convert.do")
    public ModelAndView convert(String clueId, String flag, Tran tran, HttpSession session){
        String createBy = ((User) session.getAttribute("user")).getName();
        ModelAndView mv = new ModelAndView();
        mv.setViewName("redirect:/workbench/clue/index.jsp");

        if("1".equals(flag)){
            //需要创建交易，接收参数
            tran.setId(UUIDUtil.getUUID());
            tran.setCreateTime(DateTimeUtil.getSysTime());
            tran.setCreateBy(createBy);
        }else if("0".equals(flag)){
            //不需要创建交易
            tran = null;
        }

        try {
            clueService.convert(tran, clueId, createBy);
        } catch (Exception e) {
            //转换失败
            e.printStackTrace();
            mv.addObject("isConvert", false);
            return mv;
        }
        //转换成功
        mv.addObject("isConvert", true);
        return mv;
    }
}
