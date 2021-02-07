package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityDao {
    //添加一条市场活动
    int save(Activity activity);

    //条件查询，获得总记录数
    int getTotalByCondition(Map<String, Object> map);

    //条件查询，获取所有市场活动记录
    List<Activity> getActivityListByCondition(Map<String, Object> map);

    //删除市场活动
    int deleteByIds(String[] ids);

    //通过id查询市场活动
    Activity getById(String id);

    //更新市场活动
    int update(Activity activity);

    //通过id查询市场活动，需要多表联查，将owner关联到所有者的姓名
    Activity detail(String id);

    //根据线索id和市场活动名称查询其未关联的市场活动
    List<Activity> getNotRelatedActivityListByName(Map<String, String> map);

    //根据市场活动名称模糊查询
    List<Activity> getActivityListByName(String name);

    //根据线索id查询线索关联的市场活动
    List<Activity> getRelatedActivityListByClueId(String clueId);
}
