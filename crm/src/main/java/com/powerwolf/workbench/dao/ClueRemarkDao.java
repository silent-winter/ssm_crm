package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {
    //根据线索id查询该线索的所有备注
    List<ClueRemark> getClueRemarkListById(String clueId);

    //根据线索备注id删除线索备注
    int deleteClueRemarkById(String clueRemarkId);
}
