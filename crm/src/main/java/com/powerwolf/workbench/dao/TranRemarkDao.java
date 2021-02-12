package com.powerwolf.workbench.dao;

public interface TranRemarkDao {
    //根据交易id查询备注条数
    int getTotalByTranId(String tranId);

    //删除交易备注
    int deleteTranRemarkByTranId(String tranId);
}
