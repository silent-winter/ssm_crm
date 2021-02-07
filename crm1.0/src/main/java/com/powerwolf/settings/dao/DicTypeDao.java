package com.powerwolf.settings.dao;

import com.powerwolf.settings.domain.DicType;

import java.util.List;

public interface DicTypeDao {
    //取得所有字典类型的集合
    List<DicType> getTypeList();
}
