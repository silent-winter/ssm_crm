package com.powerwolf.workbench.service.impl;

import com.powerwolf.settings.dao.UserDao;
import com.powerwolf.settings.domain.User;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.dao.ActivityDao;
import com.powerwolf.workbench.dao.ActivityRemarkDao;
import com.powerwolf.workbench.domain.Activity;
import com.powerwolf.workbench.domain.ActivityRemark;
import com.powerwolf.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ActivityServiceImpl implements ActivityService {
    @Autowired
    private ActivityDao activityDao;
    @Autowired
    private ActivityRemarkDao activityRemarkDao;
    @Autowired
    private UserDao userDao;

    @Override
    public boolean save(Activity activity){
        return activityDao.save(activity) == 1;
    }

    @Override
    public PaginationVO<Activity> pageList(Map<String, Object> map) {
        //取得total
        int total = activityDao.getTotalByCondition(map);

        //取得dataList
        List<Activity> dataList = activityDao.getActivityListByCondition(map);

        //创建vo对象，将total和dataList封装到vo中
        PaginationVO<Activity> vo = new PaginationVO<>();
        vo.setTotal(total);
        vo.setDataList(dataList);

        return vo;
    }

    @Override
    @Transactional
    public boolean delete(String[] ids) throws RuntimeException {
        //查询出需要删除的备注的数量
        int count1 = activityRemarkDao.getCountByIds(ids);

        //删除备注，返回受到影响的条数(实际删除的数量)
        int count2 = activityRemarkDao.deleteByIds(ids);
        if(count1 != count2){
           throw new RuntimeException("删除市场活动备注失败");
        }

        //删除市场活动
        int count3 = activityDao.deleteByIds(ids);
        if(count3 != ids.length){
            throw new RuntimeException("删除市场活动失败");
        }

        return true;
    }

    @Override
    public Map<String, Object> edit(String id) {
        //取userList
        List<User> userList = userDao.getUserList();

        //取activity
        Activity activity = activityDao.getById(id);

        Map<String, Object> map = new HashMap<>();
        map.put("userList", userList);
        map.put("activity", activity);

        return map;
    }

    @Override
    public boolean update(Activity activity) {
        return activityDao.update(activity) == 1;
    }

    @Override
    public Activity getDetail(String id) {
        return activityDao.detail(id);
    }

    @Override
    public List<ActivityRemark> getRemarkList(String activityId) {
        return activityRemarkDao.getRemarkListById(activityId);
    }

    @Override
    public boolean deleteRemark(String id) {
        return activityRemarkDao.deleteByRemarkId(id) == 1;
    }

    @Override
    public boolean addRemark(ActivityRemark activityRemark) {
        return activityRemarkDao.saveRemark(activityRemark) == 1;
    }

    @Override
    public boolean editRemark(ActivityRemark activityRemark) {
        return activityRemarkDao.updateRemark(activityRemark) == 1;
    }

    @Override
    public List<Activity> getActivityListByName(String name) {
        return activityDao.getActivityListByName(name);
    }

    @Override
    public List<Activity> getUnrelatedActivityListByName(Map<String, String> map) {
        return activityDao.getNotRelatedActivityListByName(map);
    }

    @Override
    public List<Activity> getRelatedActivityListByClueId(String clueId) {
        return activityDao.getRelatedActivityListByClueId(clueId);
    }
}
