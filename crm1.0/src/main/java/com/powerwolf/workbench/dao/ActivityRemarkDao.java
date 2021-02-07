package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkDao {
    //查询出需要删除的备注数量
    int getCountByIds(String[] ids);

    //根据市场活动id删除市场活动备注，返回受到影响的条数
    int deleteByIds(String[] ids);

    //根据市场活动id获得备注信息列表
    List<ActivityRemark> getRemarkListById(String activityId);

    //根据备注id删除备注信息
    int deleteByRemarkId(String id);

    //创建备注信息
    int saveRemark(ActivityRemark activityRemark);

    //修改备注信息
    int updateRemark(ActivityRemark activityRemark);
}
