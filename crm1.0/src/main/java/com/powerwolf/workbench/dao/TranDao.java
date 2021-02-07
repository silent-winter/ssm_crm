package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {
    //添加一条交易
    int addTran(Tran tran);

    //查询总记录数
    int getTotalByCondition(Map<String, Object> map);

    //分页查询
    List<Tran> pageList(Map<String, Object> map);

    //根据id查询交易信息
    Tran getTranById(String id);

    //更新交易记录
    int updateTran(Tran tran);

    //分组查询各阶段的交易数量
    List<Map<String, Object>> getCountGroupByStage();
}
