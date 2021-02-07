<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
	request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript">
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
	$(function(){
		$(".time").datetimepicker({
			minView: "month",
			language: 'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});

		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
			}else{
				$("#create-transaction2").hide(200);
			}
		});


		//为放大镜图标绑定事件
		$("#glass").click(function () {
			//打开搜索市场活动的模态窗口
			$("#searchActivityModal").modal("show");
		});


		//为搜索框绑定事件
		$("#searchBox").keydown(function (event) {
			if(event.keyCode === 13){
				//回车键，查询并展现市场活动列表
				$.ajax({
					url: "workbench/clue/getConvertActivity.do",
					data: {
						"name": $.trim($("#searchBox").val())
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
							html += '<td><input value="'+ n.id +'" type="radio" name="xz"/></td>';
							html += '<td id="'+ n.id +'">'+ n.name +'</td>';
							html += '<td>'+ n.startDate +'</td>';
							html += '<td>'+ n.endDate +'</td>';
							html += '<td>'+ n.owner +'</td>';
							html += '</tr>';
						});
						$("#searchActivityBody").html(html);
					}
				});
				return false;
			}
		});


		//为提交按钮绑定事件
		$("#submitBtn").click(function () {
			//取id和文本
			var $xz = $("input[name=xz]:checked");
			var id = $xz.val();
			var text = $("#" + id).html();

			//填充文本，保存id
			$("#activity").val(text);
			$("#hidden-activityId").val(id);

			//关闭模态窗口
			$("#searchActivityModal").modal("hide");
		});


		//为转换按钮绑定事件
		$("#convertBtn").click(function () {
			/*
				提交请求到后台，发出传统请求，响应回线索的列表页上
			 */
			if($("#isCreateTransaction").prop("checked")){
				//需要创建交易，提交表单
				$("#tranForm").submit();
			}else{
				//不需要创建交易
				window.location.href = "workbench/clue/convert.do?clueId=${param.id}&flag=0";
			}
		});

	});
</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="searchBox" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="searchActivityBody">
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
							<!--
								动态拼接搜索的市场活动
							-->
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="submitBtn">提交</button>
				</div>
			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small>${param.fullname}${param.appellation}-${param.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${param.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${param.fullname}${param.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
		<form id="tranForm" action="workbench/clue/convert.do" method="post">
			<!--线索id-->
			<input type="hidden" name="clueId" value="${param.id}">
			<!--是否创建交易的标记-->
			<input type="hidden" name="flag" value="1">
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney" name="money">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" id="tradeName" name="name">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control time" id="expectedClosingDate" name="expectedDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage" class="form-control" name="stage">
		    	<option></option>
				<c:forEach items="${stage}" var="a">
					<option value="${a.value}">${a.text}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		      <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="glass" style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
		      <input type="text" class="form-control" id="activity" placeholder="点击上面搜索" readonly>
			  <!--隐藏域，存交易的市场活动id-->
			  <input type="hidden" id="hidden-activityId" name="activityId">
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${param.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" type="button" id="convertBtn" value="转换">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" id="cancelBtn" value="取消">
	</div>
</body>
</html>