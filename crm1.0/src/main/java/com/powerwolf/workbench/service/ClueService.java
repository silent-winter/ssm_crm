package com.powerwolf.workbench.service;

import com.powerwolf.exception.ConvertException;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Activity;
import com.powerwolf.workbench.domain.Clue;
import com.powerwolf.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface ClueService {
    //创建线索
    boolean createClue(Clue clue);

    //获得分页查询结果
    PaginationVO<Clue> pageList(Map<String, Object> map);

    //获取线索的详细信息
    Clue getDetail(String id);

    //解除关联关系
    boolean unbound(String relationId);

    //关联市场活动
    void bound(String clueId, String[] activityId);

    //线索转换
    void convert(Tran tran, String clueId, String createBy) throws ConvertException;
}
