package com.powerwolf.workbench.service.impl;

import com.powerwolf.exception.ConvertException;
import com.powerwolf.utils.DateTimeUtil;
import com.powerwolf.utils.UUIDUtil;
import com.powerwolf.vo.PaginationVO;
import com.powerwolf.workbench.dao.*;
import com.powerwolf.workbench.domain.*;
import com.powerwolf.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class ClueServiceImpl implements ClueService {
    @Autowired
    private ActivityDao activityDao;

    //线索相关表
    @Autowired
    private ClueDao clueDao;
    @Autowired
    private ClueRemarkDao clueRemarkDao;
    @Autowired
    private ClueActivityRelationDao clueActivityRelationDao;

    //客户相关表
    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private CustomerRemarkDao customerRemarkDao;

    //联系人相关表
    @Autowired
    private ContactsDao contactsDao;
    @Autowired
    private ContactsRemarkDao contactsRemarkDao;
    @Autowired
    private ContactsActivityRelationDao contactsActivityRelationDao;

    //交易相关表
    @Autowired
    private TranDao tranDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;


    @Override
    public boolean createClue(Clue clue) {
        return clueDao.addClue(clue) == 1;
    }

    @Override
    public PaginationVO<Clue> pageList(Map<String, Object> map) {
        //取得线索总记录数
        int total = clueDao.getTotalByCondition(map);

        //取得每条线索，封装成对象
        List<Clue> clueList = clueDao.selectAllClueByCondition(map);

        PaginationVO<Clue> paginationVO = new PaginationVO<>();
        paginationVO.setTotal(total);
        paginationVO.setDataList(clueList);

        return paginationVO;
    }

    @Override
    public Clue getDetail(String id) {
        return clueDao.getByClueId(id);
    }

    @Override
    public boolean unbound(String relationId) {
        return clueActivityRelationDao.deleteByRelationId(relationId) == 1;
    }

    @Override
    @Transactional
    public void bound(String clueId, String[] activityId) throws RuntimeException {
        for (String aid : activityId){
            //取得每一个aid和clueId做关联
            ClueActivityRelation relation = new ClueActivityRelation();
            relation.setId(UUIDUtil.getUUID());
            relation.setClueId(clueId);
            relation.setActivityId(aid);

            //添加关联记录
            int count = clueActivityRelationDao.addRelation(relation);
            if(count != 1){
                throw new RuntimeException("关联市场活动失败");
            }
        }
    }

    @Override
    @Transactional
    public void convert(Tran tran, String clueId, String createBy) throws ConvertException {
        String createTime = DateTimeUtil.getSysTime();

        //1.通过线索id获取线索对象
        Clue clue = clueDao.getInfoByClueId(clueId);

        //2.通过线索对象提取客户信息，当客户不存在时新建客户(根据公司名称精确匹配)
        String company = clue.getCompany();
        Customer customer = customerDao.getCustomerByName(company);
        if(customer == null){
            //需要新建客户
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(clue.getOwner());
            customer.setName(company);
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setCreateBy(createBy);
            customer.setCreateTime(createTime);
            customer.setContactSummary(clue.getContactSummary());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setDescription(clue.getDescription());
            customer.setAddress(clue.getAddress());
            //添加客户
            if(customerDao.addCustomer(customer) != 1){
                throw new ConvertException("添加客户失败");
            }
        }

        //3.通过线索对象提取联系人信息
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setSource(clue.getSource());
        contacts.setOwner(clue.getOwner());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setFullname(clue.getFullname());
        contacts.setEmail(clue.getEmail());
        contacts.setDescription(clue.getDescription());
        contacts.setCustomerId(customer.getId());
        contacts.setCreateTime(createTime);
        contacts.setCreateBy(createBy);
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setAppellation(clue.getAppellation());
        contacts.setAddress(clue.getAddress());
        //添加联系人
        if(contactsDao.addContacts(contacts) != 1){
            throw new ConvertException("添加联系人失败");
        }

        //4.将线索的备注转换为联系人备注和客户备注
        List<ClueRemark> clueRemarkList = clueRemarkDao.getClueRemarkListById(clueId);
        for (ClueRemark clueRemark : clueRemarkList){
            //添加客户备注
            CustomerRemark customerRemark = new CustomerRemark();
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setCreateBy(createBy);
            customerRemark.setCreateTime(createTime);
            customerRemark.setCustomerId(customer.getId());
            customerRemark.setEditFlag("0");
            customerRemark.setNoteContent(clueRemark.getNoteContent());
            if(customerRemarkDao.addCustomerRemark(customerRemark) != 1){
                throw new ConvertException("添加客户备注失败");
            }

            //添加联系人备注
            ContactsRemark contactsRemark = new ContactsRemark();
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setContactsId(contacts.getId());
            contactsRemark.setEditFlag("0");
            contactsRemark.setNoteContent(clueRemark.getNoteContent());
            if(contactsRemarkDao.addContactsRemark(contactsRemark) != 1){
                throw new ConvertException("添加联系人备注失败");
            }

            //删除线索备注
            String clueRemarkId = clueRemark.getId();
            if(clueRemarkDao.deleteClueRemarkById(clueRemarkId) != 1){
                throw new ConvertException("删除线索备注失败");
            }
        }

        //5."线索和市场活动"的关联关系转换到"联系人和市场活动"的关联关系
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getRelationByClueId(clueId);
        for (ClueActivityRelation clueActivityRelation : clueActivityRelationList){
            //取得关联的市场活动id
            String activityId = clueActivityRelation.getActivityId();

            //与联系人做关联
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setActivityId(activityId);
            contactsActivityRelation.setContactsId(contacts.getId());
            if(contactsActivityRelationDao.addRelation(contactsActivityRelation) != 1){
                throw new ConvertException("联系人关联市场活动失败");
            }

            //删除线索与市场活动的关联关系
            if(clueActivityRelationDao.delete(clueActivityRelation) != 1){
                throw new ConvertException("删除线索市场活动关联关系失败");
            }
        }

        //6.如果有创建交易需求，创建一条交易
        if(tran != null){
            tran.setSource(clue.getSource());
            tran.setOwner(clue.getOwner());
            tran.setNextContactTime(clue.getNextContactTime());
            tran.setDescription(clue.getDescription());
            tran.setCustomerId(customer.getId());
            tran.setContactSummary(clue.getContactSummary());
            tran.setContactsId(contacts.getId());

            //添加交易
            if(tranDao.addTran(tran) != 1){
                throw new ConvertException("添加交易失败");
            }

            //7.如果创建了交易，添加一条交易历史
            TranHistory tranHistory = new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setStage(tran.getStage());
            tranHistory.setTranId(tran.getId());

            //添加交易历史
            if(tranHistoryDao.addTranHistory(tranHistory) != 1){
                throw new ConvertException("添加交易历史失败");
            }
        }

        //9.删除线索
        if(clueDao.deleteById(clueId) != 1){
            throw new ConvertException("删除线索失败");
        }
    }



}
