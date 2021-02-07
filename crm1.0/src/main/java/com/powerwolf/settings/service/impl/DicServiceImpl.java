package com.powerwolf.settings.service.impl;

import com.powerwolf.settings.dao.DicTypeDao;
import com.powerwolf.settings.dao.DicValueDao;
import com.powerwolf.settings.domain.DicType;
import com.powerwolf.settings.domain.DicValue;
import com.powerwolf.settings.service.DicService;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DicServiceImpl implements DicService {
    private DicTypeDao dicTypeDao;
    private DicValueDao dicValueDao;

    public void setDicTypeDao(DicTypeDao dicTypeDao) {
        this.dicTypeDao = dicTypeDao;
    }

    public void setDicValueDao(DicValueDao dicValueDao) {
        this.dicValueDao = dicValueDao;
    }

    @Override
    public Map<String, List<DicValue>> getKeyMapperList() {
        Map<String, List<DicValue>> map = new HashMap<>();
        //将字典类型列表取出
        List<DicType> typeList = dicTypeDao.getTypeList();

        //将字典类型列表遍历，对每个类型取出它对应的字典值
        for(DicType dicType : typeList){
            //取出字典类型
            String code = dicType.getCode();

            //取字典值列表
            List<DicValue> valueList = dicValueDao.getValuesByType(code);

            map.put(code, valueList);
        }
        return map;
    }
}
