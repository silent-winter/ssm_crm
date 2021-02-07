package com.powerwolf.workbench.service;

import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.domain.Tran;
import com.powerwolf.workbench.domain.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {
    //分页查询，返回查询结果
    PaginationVO<Tran> pageList(Map<String, Object> map);

    //创建一条新交易，如果联系人不存在，则新建联系人
    void addTran(Tran tran, String customerName);

    //根据id查询交易详细信息
    Tran getDetail(String id);

    //根据交易id获取交易历史列表
    List<TranHistory> getTranHistoryList(String tranId);

    //变更交易阶段，并生成交易历史
    void changeStage(Tran tran);

    //取得交易总数和各阶段的数量
    PaginationVO<Map<String, Object>> getCharts();
}
