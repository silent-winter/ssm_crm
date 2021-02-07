package com.powerwolf.settings.service;

import com.powerwolf.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

public interface DicService {
    //取得数据字典中每个key对应的value集合(list)
    Map<String, List<DicValue>> getKeyMapperList();

}
