package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.Activity;
import com.powerwolf.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {
    //添加一条线索记录
    int addClue(Clue clue);

    //根据搜索条件查询线索总条数
    int getTotalByCondition(Map<String, Object> map);

    //根据搜索条件查询所有线索
    List<Clue> selectAllClueByCondition(Map<String, Object> map);

    //根据线索id查询线索，owner保存值
    Clue getByClueId(String id);

    //根据线索id查询线索，owner保存外键
    Clue getInfoByClueId(String id);

    //根据线索id删除线索
    int deleteById(String id);
}
