package com.powerwolf.workbench.service;

import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Activity;
import com.powerwolf.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    //保存市场活动
    boolean save(Activity activity);

    //查询分页信息
    PaginationVO<Activity> pageList(Map<String, Object> map);

    //删除市场活动
    boolean delete(String[] ids) throws Exception;

    //修改市场活动模态窗口的信息获取
    Map<String, Object> edit(String id);

    //更新市场活动
    boolean update(Activity activity);

    //获取市场活动的详细信息页
    Activity getDetail(String id);

    //根据市场活动id取得备注列表
    List<ActivityRemark> getRemarkList(String id);

    //根据备注id删除备注信息
    boolean deleteRemark(String id);

    //添加备注
    boolean addRemark(ActivityRemark activityRemark);

    //修改备注
    boolean editRemark(ActivityRemark activityRemark);

    //根据名称获取市场活动列表
    List<Activity> getActivityListByName(String name);

    //根据市场活动名称模糊查询，获取该线索还没有关联的市场活动
    List<Activity> getUnrelatedActivityListByName(Map<String, String> map);

    //获取线索关联的市场活动列表
    List<Activity> getRelatedActivityListByClueId(String clueId);
}
