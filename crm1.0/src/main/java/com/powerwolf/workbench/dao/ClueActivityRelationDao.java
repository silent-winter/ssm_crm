package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {
    //根据关联关系id解除关系
    int deleteByRelationId(String relationId);

    //添加关联关系
    int addRelation(ClueActivityRelation clueActivityRelation);

    //根据线索id查询其关联的市场活动id
    List<ClueActivityRelation> getRelationByClueId(String clueId);

    //根据线索id删除关联关系
    int delete(ClueActivityRelation clueActivityRelation);
}
