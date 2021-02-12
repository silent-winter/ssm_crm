<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
            request.getServerPort() + request.getContextPath() + "/";

    Map<String, String> pMap = (Map<String, String>) application.getAttribute("possibility");
    Set<String> set = pMap.keySet();
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <!--自动补全-->
    <script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
    <script type="text/javascript">

        var json = {
            <%
                for(String key : set){
                    String value = pMap.get(key);
            %>
            "<%=key%>" : <%=value%>,
            <%
                }
            %>
        };

        //日期拾取器语言包
        ;(function($){
            $.fn.datetimepicker.dates['zh-CN'] = {
                days: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"],
                daysShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六", "周日"],
                daysMin:  ["日", "一", "二", "三", "四", "五", "六", "日"],
                months: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
                monthsShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
                today: "今天",
                suffix: [],
                meridiem: ["上午", "下午"]
            };
        }(jQuery));
    </script>

    <script type="text/javascript">
        $(function () {

            //为阶段的下拉框绑定选中下拉框事件，根据选中的阶段填写可能性
            $("#create-stage").change(function () {
                //取得选中得阶段
                var stage = this.value;
                //将pMap转换为js得键值对关系json，取可能性
                var possibility = json[stage];
                //填写可能性
                $("#create-possibility").val(possibility);
            });


            //设置用户下拉选项框的默认值：当前登录用户
            $("#create-transactionOwner").val("${user.id}");


            $(".topTime").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "top-left"
            });
            $(".bottomTime").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });


            //为查找市场活动的搜索框绑定事件
            $("#searchActivityBox").keydown(function (e) {
                if(e.keyCode === 13){
                    $.ajax({
                        url: "workbench/transaction/searchActivity.do",
                        data: {
                            "name": $.trim($("#searchActivityBox").val())
                        },
                        type: "get",
                        dataType: "json",
                        success: function (data) {
                            /*
                            data
                                [{市场活动1}, {市场活动1}, ...]
                         */
                            var html = "";
                            $.each(data, function (i, n) {
                                html += '<tr>';
                                html += '<td><input value="'+ n.id +'" type="radio" name="activity"/></td>';
                                html += '<td id="'+ n.id +'">'+ n.name +'</td>';
                                html += '<td>'+ n.startDate +'</td>';
                                html += '<td>'+ n.endDate +'</td>';
                                html += '<td>'+ n.owner +'</td>';
                                html += '</tr>';
                            });
                            $("#activityBody").html(html);
                        }
                    });
                    return false;
                }
            });


            //为查找联系人的搜索框绑定事件
            $("#searchContactsBox").keydown(function (e) {
                if(e.keyCode === 13){
                    $.ajax({
                        url: "workbench/customer/searchContacts.do",
                        data: {
                            "name": $.trim($("#searchContactsBox").val()),
                            "customerId": "${customer.id}"
                        },
                        type: "get",
                        dataType: "json",
                        success: function (data) {
                            /*
                            data
                                [{联系人1}, {联系人1}, ...]
                         */
                            var html = "";
                            $.each(data, function (i, n) {
                                html += '<tr>';
                                html += '<td><input type="radio" value="'+ n.id +'" name="contacts"/></td>';
                                html += '<td id="'+ n.id +'">'+ n.fullname +'</td>';
                                html += '<td>'+ n.email +'</td>';
                                html += '<td>'+ n.mphone +'</td>';
                                html += '</tr>';
                            });
                            $("#contactsBody").html(html);
                        }
                    });
                    return false;
                }
            });


            //为提交按钮绑定事件
            $("#submitBtn1").click(function () {
                //取id和文本
                var $activity = $("input[name=activity]:checked");
                var id = $activity.val();
                var text = $("#" + id).html();

                //填充文本，保存id
                $("#create-activitySrc").val(text);
                $("#hidden-activityId").val(id);

                //清空搜索框和信息列表
                $("#activityBody").html("");
                $("#searchActivityBox").val("");
                //关闭模态窗口
                $("#findMarketActivity").modal("hide");
            });

            $("#submitBtn2").click(function () {
                //取id和文本
                var $contacts = $("input[name=contacts]:checked");
                var id = $contacts.val();
                var text = $("#" + id).html();

                //填充文本，保存id
                $("#create-contactsName").val(text);
                $("#hidden-contactsId").val(id);

                //清空搜索框和信息列表
                $("#contactsBody").html("");
                $("#searchContactsBox").val("");
                //关闭模态窗口
                $("#findContacts").modal("hide");
            });


            //为保存按钮绑定事件
            $("#saveBtn").click(function () {
                //提交表单
                $("#saveTranForm").submit();
            });


            //为取消按钮绑定事件
            $("#cancelBtn").click(function () {
                window.history.back();
            });

        });
    </script>

</head>
<body>

<!-- 查找市场活动 -->
<div class="modal fade" id="findMarketActivity" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" id="searchActivityBox" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody id="activityBody">
                    <!--<tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>-->
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="submitBtn1">提交</button>
            </div>
        </div>
    </div>
</div>

<!-- 查找联系人 -->
<div class="modal fade" id="findContacts" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找联系人</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="searchContactsBox" type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>邮箱</td>
                        <td>手机</td>
                    </tr>
                    </thead>
                    <tbody id="contactsBody">
                    <!--<tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>李四</td>
                        <td>lisi@bjpowernode.com</td>
                        <td>12345678901</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>李四</td>
                        <td>lisi@bjpowernode.com</td>
                        <td>12345678901</td>
                    </tr>-->
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="submitBtn2">提交</button>
            </div>
        </div>
    </div>
</div>


<div style="position:  relative; left: 30px;">
    <h3>创建交易</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
        <button type="button" class="btn btn-default" id="cancelBtn">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<form action="workbench/customer/saveTran.do" method="post" id="saveTranForm" class="form-horizontal" role="form" style="position: relative; top: -30px;">
    <div class="form-group">
        <label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-owner" name="owner">
                <option></option>
                <c:forEach items="${userList}" var="u">
                    <option value="${u.id}">${u.name}</option>
                </c:forEach>
            </select>
        </div>
        <label for="create-money" class="col-sm-2 control-label">金额</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-money" name="money">
        </div>
    </div>

    <div class="form-group">
        <label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-name" name="name">
        </div>
        <label for="create-expectedDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control bottomTime" id="create-expectedDate" name="expectedDate">
        </div>
    </div>

    <div class="form-group">
        <label for="create-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-customerName" name="customerName" value="${customer.name}" readonly>
        </div>
        <label for="create-stage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-stage" name="stage">
                <option></option>
                <c:forEach items="${stage}" var="v">
                    <option value="${v.value}">${v.text}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label for="create-type" class="col-sm-2 control-label">类型</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-type" name="type">
                <option></option>
                <c:forEach items="${transactionType}" var="v">
                    <option value="${v.value}">${v.text}</option>
                </c:forEach>
            </select>
        </div>
        <label for="create-possibility" class="col-sm-2 control-label">可能性</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-possibility">
        </div>
    </div>

    <div class="form-group">
        <label for="create-source" class="col-sm-2 control-label">来源</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-source" name="source">
                <option></option>
                <c:forEach items="${source}" var="v">
                    <option value="${v.value}">${v.text}</option>
                </c:forEach>
            </select>
        </div>
        <label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findMarketActivity"><span class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-activitySrc" readonly>
            <input type="hidden" id="create-activityId" name="activityId">
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findContacts"><span class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-contactsName" readonly>
            <input type="hidden" id="create-contactsId" name="contactsId">
        </div>
    </div>

    <div class="form-group">
        <label for="create-description" class="col-sm-2 control-label">描述</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="create-description" name="description"></textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control topTime" id="create-nextContactTime" name="nextContactTime">
        </div>
    </div>

</form>
</body>
</html>