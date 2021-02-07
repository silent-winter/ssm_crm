package com.powerwolf.settings.dao;

import com.powerwolf.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {
    //根据字典类型取字典值列表
    List<DicValue> getValuesByType(String type);
}
