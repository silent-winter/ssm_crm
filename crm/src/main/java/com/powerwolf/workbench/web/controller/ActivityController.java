package com.powerwolf.workbench.web.controller;

import com.powerwolf.settings.domain.User;
import com.powerwolf.settings.service.UserService;
import com.powerwolf.utils.DateTimeUtil;
import com.powerwolf.utils.UUIDUtil;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Activity;
import com.powerwolf.workbench.domain.ActivityRemark;
import com.powerwolf.workbench.service.ActivityService;
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
@RequestMapping("/workbench/activity")
public class ActivityController {
    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;

    //查询用户信息列表
    @RequestMapping(value = "/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        return userService.getUserList();
    }


    //执行市场活动的添加操作
    @RequestMapping("/save.do")
    @ResponseBody
    public Map<String, Boolean> save(Activity activity, HttpSession session){
        String id = UUIDUtil.getUUID();
        //创建时间：当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //创建人：当前登录用户
        String createBy = ((User) session.getAttribute("user")).getName();

        activity.setId(id);
        activity.setCreateTime(createTime);
        activity.setCreateBy(createBy);

        boolean flag = activityService.save(activity);
        Map<String, Boolean> mp = new HashMap<>();
        mp.put("success", flag);

        return mp;
    }


    //执行市场活动信息局部刷新
    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVO<Activity> pageList(Activity activity, String pageNo, String pageSize){
        int skipCount = (Integer.parseInt(pageNo) - 1) * Integer.parseInt(pageSize);
        Map<String, Object> map = new HashMap<>();
        map.put("name", activity.getName());
        map.put("owner", activity.getOwner());
        map.put("startDate", activity.getStartDate());
        map.put("endDate", activity.getEndDate());
        map.put("pageSize", Integer.valueOf(pageSize));
        map.put("skipCount", skipCount);

        /*
            前端需要信息：
                1.市场活动列表
                2.查询的总条数
         */
        return activityService.pageList(map);
    }


    //执行市场活动删除操作
    @RequestMapping("/delete.do")
    @ResponseBody
    public Map<String, Boolean> delete(@RequestParam("id") String[] ids){
        Map<String, Boolean> map = new HashMap<>();
        try {

            boolean flag = activityService.delete(ids);
            map.put("success", flag);
            return map;

        } catch (Exception e) {

            e.printStackTrace();
            map.put("success", false);
            return map;

        }
    }


    //市场活动修改，模态窗口的信息获取
    @RequestMapping("/edit.do")
    @ResponseBody
    public Map<String, Object> edit(String id){
        return activityService.edit(id);
    }


    //执行市场活动的更新操作
    @RequestMapping("/update.do")
    @ResponseBody
    public Map<String, Boolean> update(Activity activity, HttpSession session){
        //修改时间：当前系统时间
        String editTime = DateTimeUtil.getSysTime();
        //修改人：当前登录用户
        String editBy = ((User) session.getAttribute("user")).getName();

        activity.setEditTime(editTime);
        activity.setEditBy(editBy);

        boolean flag = activityService.update(activity);
        Map<String, Boolean> map = new HashMap<>();
        map.put("success", flag);

        return map;
    }


    //跳转到详细信息页
    @RequestMapping("/detail.do")
    public ModelAndView toDetail(String id){
        Activity activity = activityService.getDetail(id);

        //前后端信息交互，转发的视图名称
        ModelAndView mv = new ModelAndView();
        mv.addObject("activity", activity);
        mv.setViewName("/workbench/activity/detail.jsp");

        return mv;
    }


    //根据市场活动id取得备注信息列表
    @RequestMapping("/getRemark.do")
    @ResponseBody
    public List<ActivityRemark> getRemark(String activityId){
        return activityService.getRemarkList(activityId);
    }


    //删除备注
    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public Map<String, Boolean> deleteRemark(String id){
        boolean flag = activityService.deleteRemark(id);
        Map<String, Boolean> map = new HashMap<>();
        map.put("success", flag);

        return map;
    }


    //添加备注
    @RequestMapping("/saveRemark.do")
    @ResponseBody
    public Map<String, Object> saveRemark(ActivityRemark activityRemark, HttpSession session){
        String id = UUIDUtil.getUUID();
        //创建时间：当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //创建人：当前登录用户
        String createBy = ((User) session.getAttribute("user")).getName();

        activityRemark.setCreateTime(createTime);
        activityRemark.setCreateBy(createBy);
        activityRemark.setId(id);
        activityRemark.setEditFlag("0");

        boolean flag = activityService.addRemark(activityRemark);
        Map<String, Object> map = new HashMap<>();
        map.put("remark", activityRemark);
        map.put("success", flag);

        return map;
    }


    //修改备注
    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public Map<String, Object> updateRemark(ActivityRemark activityRemark, HttpSession session){
        //修改时间：当前系统时间
        String editTime = DateTimeUtil.getSysTime();
        //修改人：当前登录用户
        String editBy = ((User) session.getAttribute("user")).getName();

        activityRemark.setEditTime(editTime);
        activityRemark.setEditBy(editBy);
        activityRemark.setEditFlag("1");

        boolean flag = activityService.editRemark(activityRemark);
        Map<String, Object> map = new HashMap<>();
        map.put("remark", activityRemark);
        map.put("success", flag);

        return map;
    }
}
