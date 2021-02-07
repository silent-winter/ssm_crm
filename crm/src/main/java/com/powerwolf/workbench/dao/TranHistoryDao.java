package com.powerwolf.workbench.dao;

import com.powerwolf.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {
    //添加交易历史
    int addTranHistory(TranHistory tranHistory);

    //根据交易id查询交易历史列表
    List<TranHistory> getTranHistoryListByTranId(String tranId);
}
