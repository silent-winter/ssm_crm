<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8"%>
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
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js" charset="UTF-8"></script>

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

		//分页控件语言包
		var rsc_bs_pag = {
			go_to_page_title: 'Go to page',
			rows_per_page_title: 'Rows per page',
			current_page_label: 'Page',
			current_page_abbr_label: 'p.',
			total_pages_label: 'of',
			total_pages_abbr_label: '/',
			total_rows_label: 'of',
			rows_info_records: 'records',
			go_top_text: '首页',
			go_prev_text: '上一页',
			go_next_text: '下一页',
			go_last_text: '末页'
		};
	</script>

<script type="text/javascript">

	$(function(){
		$(".time").datetimepicker({
			minView: "month",
			language: 'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		//刷新页面
		pageList(1, 2);

		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });


		//为复选框绑定事件
		$("#selectAll").click(function () {
			$("input[name=xz]").prop("checked", this.checked);
		});
		$("#customerBody").on("click", $("input[name=xz]"), function () {
			$("#selectAll").prop("checked", $("input[name=xz]").length === $("input[name=xz]:checked").length);
		});


		//为查询按钮绑定事件
		$("#searchBtn").click(function () {
			//将查询信息保存到隐藏域
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-phone").val($.trim($("#search-phone").val()));
			$("#hidden-website").val($.trim($("#search-website").val()));
			//查询结束后刷新页面
			pageList(1, $("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
		});


		//为创建按钮绑定事件
		$("#addBtn").click(function () {
			//取得用户信息列表
			$.ajax({
				url: "workbench/customer/getUserList.do",
				type: "get",
				dataType: "json",
				success: function (data) {
					/*
						data
							[{user1}, {user2}, ...]
					 */
					var html = "";
					$.each(data, function (i, n) {
						html += "<option value ="+ n.id +">"+ n.name +"</option>"
					});
					$("#create-owner").html(html).val("${user.id}");
				}
			});
			//打开模态窗口
			$("#createCustomerModal").modal("show");
		});


		//为保存按钮绑定事件
		$("#saveBtn").click(function () {
			$.ajax({
				url: "workbench/customer/addCustomer.do",
				data:{
					"owner": $.trim($("#create-owner").val()),
					"name": $.trim($("#create-name").val()),
					"website": $.trim($("#create-website").val()),
					"phone": $.trim($("#create-phone").val()),
					"contactSummary": $.trim($("#create-contactSummary").val()),
					"nextContactTime": $.trim($("#create-nextContactTime").val()),
					"description": $.trim($("#create-description").val()),
					"address": $.trim($("#create-address").val())
				},
				type: "post",
				dataType: "json",
				success: function (data) {
					/*
						data
							{"success":true/false}
					 */
					if(data.success){
						//刷新页面
						pageList(1, $("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
						//清空表单数据
						$("#addCustomerForm")[0].reset();
						//关闭模态窗口
						$("#createCustomerModal").modal("hide");
					}else{
						alert("添加客户失败");
					}
				}
			});
		});


		//为修改按钮绑定事件
		$("#editBtn").click(function () {
			var $xz = $("input[name=xz]:checked");
			if($xz.length === 0) {
				alert("请选择要修改的记录");
			}else if($xz.length > 1) {
				alert("只能选择一条记录进行修改");
			}else{
				//查询选中项的原信息
				$.ajax({
					url: "workbench/customer/getCustomerInfo.do",
					data: {
						"id": $xz.val()
					},
					type: "post",
					dataType: "json",
					success: function (data) {
						/*
                            data：用户列表，市场活动对象
                                { "userList":[], "customer":[]}
                         */
						var html = "";
						$.each(data.userList, function (i, n) {
							html += "<option value ="+ n.id +">"+ n.name +"</option>"
						});
						$("#edit-owner").html(html).val(data.customer.owner);
						$("#edit-id").val(data.customer.id);
						$("#edit-name").val(data.customer.name);
						$("#edit-website").val(data.customer.website);
						$("#edit-phone").val(data.customer.phone);
						$("#edit-description").val(data.customer.description);
						$("#edit-contactSummary").val(data.customer.contactSummary);
						$("#edit-nextContactTime").val(data.customer.nextContactTime);
						$("#edit-address").val(data.customer.address);
						//打开修改客户的模态窗口
						$("#editCustomerModal").modal("show");
					}
				});
			}
		});


		//为更新按钮绑定事件
		$("#updateBtn").click(function () {
			$.ajax({
				url: "workbench/customer/editCustomer.do",
				data: {
					"id": $.trim($("#edit-id").val()),
					"owner": $.trim($("#edit-owner").val()),
					"name": $.trim($("#edit-name").val()),
					"website": $.trim($("#edit-website").val()),
					"phone": $.trim($("#edit-phone").val()),
					"contactSummary": $.trim($("#edit-contactSummary").val()),
					"nextContactTime": $.trim($("#edit-nextContactTime").val()),
					"description": $.trim($("#edit-description").val()),
					"address": $.trim($("#edit-address").val())
				},
				type: "post",
				dataType: "json",
				success: function (data) {
					/*
						data
							{"success":true/false}
					 */
					if(data.success){
						//刷新客户信息列表
						pageList($("#customerPage").bs_pagination('getOption', 'currentPage')
								,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
						//关闭模态窗口
						$("#editCustomerModal").modal("hide");
					}else{
						alert("修改客户失败");
					}
				}
			})
		});


		//为删除按钮绑定事件
		$("#deleteBtn").click(function () {
			var $id = $("input[name=xz]:checked");
			if($id.length === 0){
				alert("请选择要删除的客户");
			}else{
				if(confirm("是否确认删除选中客户")){
					var id = "";
					for(var i = 0; i < $id.length; i++){
						id += ("id=" + $id[i].value);
						if(i < $id.length - 1){
							id += "&";
						}
					}
					$.ajax({
						url: "workbench/customer/deleteCustomer.do",
						data: id,
						type: "post",
						dataType: "json",
						success: function (data) {
							/*
                                data
                                    {"success":true/false}
                             */
							if(data.success){
								//刷新客户信息列表
								pageList(1 ,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
							}else{
								alert("删除客户失败");
							}
						}
					})
				}
			}
		});


	});


	function pageList(pageNo, pageSize) {
		//将全选的复选框的√去掉
		$("#selectAll").prop("checked", false);

		//查询前，先将隐藏域中保存的信息取出来，重新赋予到搜索框中
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-phone").val($.trim($("#hidden-phone").val()));
		$("#search-website").val($.trim($("#hidden-website").val()));

		$.ajax({
			url: "workbench/customer/pageList.do",
			data: {
				"pageNo": pageNo,
				"pageSize": pageSize,
				"name": $.trim($("#search-name").val()),
				"owner": $.trim($("#search-owner").val()),
				"phone": $.trim($("#search-phone").val()),
				"website": $.trim($("#search-website").val()),
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				/*
					data
						["total":xxx, "dataList":{客户1}, {客户2}, ...]
				 */
				var html = "";
				$.each(data.dataList, function (i, n) {
					html += '<tr>';
					html += '<td><input type="checkbox" name="xz" value="'+ n.id +'"/></td> ';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/customer/detail.do?id='+ n.id +'\';">'+ n.name +'</a></td>';
					html += '<td>'+ n.owner +'</td>';
					html += '<td>'+ n.phone +'</td>';
					html += '<td>'+ n.website +'</td>';
					html += '</tr>';
				});
				$("#customerBody").html(html);

				//计算总页数
				var totalPages = data.total % pageSize === 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;

				//数据处理完毕后，结合分页插件，对前端展现分页信息
				$("#customerPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数
					visiblePageLinks: 3, // 显示几个卡片
					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//点击分页组件的时候触发
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});
			}
		})
	}
	
</script>
</head>
<body>
	<!--保存搜索框中的信息到隐藏域-->
	<input type="hidden" id="hidden-name" />
	<input type="hidden" id="hidden-owner" />
	<input type="hidden" id="hidden-phone" />
	<input type="hidden" id="hidden-website" />

	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="addCustomerForm">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								  <!--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>-->
								</select>
							</div>
							<label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-name">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="create-nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<!--隐藏域保存客户id-->
						<input type="hidden" id="edit-id">
					
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
								  <option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>
								</select>
							</div>
							<label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-name" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="edit-nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address">北京大兴大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>客户列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control" type="text" id="search-website">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="selectAll"/></td>
							<td>名称</td>
							<td>所有者</td>
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody id="customerBody">
						<!--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点</a></td>
							<td>zhangsan</td>
							<td>010-84846003</td>
							<td>http://www.bjpowernode.com</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点</a></td>
                            <td>zhangsan</td>
                            <td>010-84846003</td>
                            <td>http://www.bjpowernode.com</td>
                        </tr>-->
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="customerPage">
					<!--分页信息-->
				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>