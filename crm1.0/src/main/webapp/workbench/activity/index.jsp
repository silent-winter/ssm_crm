<%@ page contentType="text/html;charset=UTF-8" language="java"
		 pageEncoding="utf-8" %>
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

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js" charset="UTF-8"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js" charset="UTF-8"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<!--<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js" charset="UTF-8"></script>-->

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js" charset="UTF-8"></script>
	<!--<script type="text/javascript" src="jquery/bs_pagination/en.js" charset="UTF-8"></script>-->

	<script type="text/javascript">
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



	$(function(){
		//为创建按钮绑定事件，打开模态窗口
		$("#addBtn").click(function () {

			$(".time").datetimepicker({
				minView: "month",
				language: 'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});


			//取得用户信息列表
			$.ajax({
				url: "workbench/activity/getUserList.do",
				type: "get",
				dataType: "json",
				success: function (data) {
					/*
						data:
							[{用户1}，{用户2}，...]
					 */
					var html = "<option></option>";

					//遍历出来的每一个n，就是每一个User对象
					//value：发送到后台的数据
					$.each(data, function (i, n) {
						html += "<option value='" + n.id + "'>" + n.name + "</option>";
					});
					$("#create-marketActivityOwner").html(html);


					//将当前登录的用户设置为下拉框默认选项
					//在js中使用el表达式必须要加引号
					var id = "${user.id}";
					$("#create-marketActivityOwner").val(id);


					//所有者下拉框处理完后，展现模态窗口
					/*
						操作模态窗口的方式：
							调用窗口对象的modal方法，传递参数(show：打开模态窗口，hide：关闭)
					 */
					$("#createActivityModal").modal("show");
				}
			})
		});

		//为保存按钮绑定事件
		$("#saveBtn").click(function () {
			$.ajax({
				url: "workbench/activity/save.do",
				data: {
					"owner" : $.trim($("#create-marketActivityOwner").val()),
					"name" : $.trim($("#create-marketActivityName").val()),
					"startDate" : $.trim($("#create-startDate").val()),
					"endDate" : $.trim($("#create-endDate").val()),
					"cost" : $.trim($("#create-cost").val()),
					"description" : $.trim($("#create-description").val())
				},
				type: "post",
				dataType: "json",
				success: function (data) {
					/*
						data
							{"success":true/false}
					 */
					if(data.success){
						//保存成功，刷新页面
						pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

						//清空添加操作后模态窗口中的数据
						//注意：原生js对象才有reset()方法，所以先要将jquery对象转为dom对象
						$("#activityAddForm")[0].reset();

						//关闭模态窗口
						$("#createActivityModal").modal("hide");
					}else{
						alert("添加市场活动失败")
					}
				}
			})
		});

		//页面加载完毕后，触发分页查询方法
		//默认展开列表第一页，每页两条记录
		pageList(1, 2);

		//为查询按钮绑定事件
		$("#searchBtn").click(function () {
			/*
				点击查询按钮的时候，将查询框的信息保存起来
			 */
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-startDate").val($.trim($("#search-startDate").val()));
			$("#hidden-endDate").val($.trim($("#search-endDate").val()));

			//查询结束后刷新页面
			pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
		});

		//为全选的复选框绑定事件
		$("#selectAll").click(function () {
			//this表示选择出来的jquery对象
			$("input[name=xz]").prop("checked", this.checked);
		});
		/*
			动态生成的元素(js拼接)，要以on方法的形式来触发事件
			语法：$(需要绑定元素的有效外层元素).on(绑定事件的方式，需要绑定的元素的jquery对象，回调函数)
		 */
		$("#activityBody").on("click", $("input[name=xz]"), function () {
			$("#selectAll").prop("checked", $("input[name=xz]").length === $("input[name=xz]:checked").length);
		});


		//为删除按钮绑定事件
		$("#deleteBtn").click(function () {
			//找到复选框中被选中的jquery对象
			var $xz = $("input[name=xz]:checked");

			if($xz.length === 0){
				alert("请选择要删除的记录");
			}else{
				if(confirm("确定删除所选中的记录吗")){
					var param = "";
					for(var i = 0; i < $xz.length; i++){
						if(i !== $xz.length - 1){
							param += ("id="+$($xz[i]).val()+"&");
						}else{
							param += ("id="+$($xz[i]).val());
						}
					}

					$.ajax({
						url: "workbench/activity/delete.do",
						data: param,
						type: "post",
						dataType: "json",
						success: function (data) {
							/*
                                data
                                    {success:true/false}
                             */
							if(data.success){
								//删除成功，刷新页面
								pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

							}else{
								alert("删除市场活动失败");
							}
						}
					})
				}
			}
		});


		//为修改按钮绑定事件
		$("#editBtn").click(function () {
			//走后台，拿到要修改记录的后台信息
			//找到复选框中被选中的jquery对象
			var $xz = $("input[name=xz]:checked");
			if($xz.length === 0) {
				alert("请选择要修改的记录");
			}else if($xz.length > 1){
				alert("只能选择一条记录进行修改");
			}else{
				var id = $xz.val();
				$.ajax({
					url: "workbench/activity/edit.do",
					data: {
						"id": id,
					},
					type: "get",
					dataType: "json",
					success: function (data) {
						/*
                            data：用户列表，市场活动对象
                                { "userList":[], "activity":[]}
                         */
						var html = "<option></option>";
						$.each(data.userList, function (i, n) {
							html += "<option value='"+ n.id +"'>"+ n.name +"</option>";
						});
						$("#edit-owner").html(html);

						//处理单条市场活动
						$("#edit-id").val(data.activity.id);
						$("#edit-owner").val(data.activity.owner);
						$("#edit-name").val(data.activity.name);
						$("#edit-startDate").val(data.activity.startDate);
						$("#edit-endDate").val(data.activity.endDate);
						$("#edit-cost").val(data.activity.cost);
						$("#edit-description").val(data.activity.description);

						//打开修改操作的模态窗口
						$("#editActivityModal").modal("show");
					}
				})
			}
		});


		//为更新按钮绑定事件
		$("#updateBtn").click(function () {
			$.ajax({
				url: "workbench/activity/update.do",
				data: {
					"id" : $.trim($("#edit-id").val()),
					"owner" : $.trim($("#edit-owner").val()),
					"name" : $.trim($("#edit-name").val()),
					"startDate" : $.trim($("#edit-startDate").val()),
					"endDate" : $.trim($("#edit-endDate").val()),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-description").val())
				},
				type: "post",
				dataType: "json",
				success: function (data) {
					/*
						data
							{"success":true/false}
					 */
					if(data.success){
						//刷新市场活动信息列表
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

						//关闭模态窗口
						$("#editActivityModal").modal("hide");
					}else{
						alert("修改市场活动失败")
					}
				}
			})
		});

	});

	/*
		发出ajax请求到后台，局部刷新市场活动列表
		pageNo：页码
		pageSize：每页展现的记录数

		调用情况：
			(1)点击左侧菜单"市场活动"超链接
			(2)添加、删除、修改后
			(3)点击查询功能按钮后
			(4)点击分页组件后

		$("#activityPage").bs_pagination('getOption', 'currentPage')：
			操作后停留在当前页
		$("#activityPage").bs_pagination('getOption', 'rowsPerPage')：
			操作后维持已经设置好的每页展现的记录数
		pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
				,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

	 */
	function pageList(pageNo, pageSize) {
		//将全选的复选框的√去掉
		$("#selectAll").prop("checked", false);

		//查询前，先将隐藏域中保存的信息取出来，重新赋予到搜索框中
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-startDate").val($.trim($("#hidden-startDate").val()));
		$("#search-endDate").val($.trim($("#hidden-endDate").val()));

		$.ajax({
			url: "workbench/activity/pageList.do",
			data: {
				"pageNo": pageNo,
				"pageSize": pageSize,
				"name": $.trim($("#search-name").val()),
				"owner": $.trim($("#search-owner").val()),
				"startDate": $.trim($("#search-startDate").val()),
				"endDate": $.trim($("#search-endDate").val())
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				/*
					data
						{"total":100, "datalist": [{市场活动1}, {市场活动2}, ..., ]}
				 */
				var html = "";
				$.each(data.dataList, function (i, n) {
					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="xz" value='+ n.id +'></td>';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+ n.id +'\';">'+ n.name +'</a></td>';
					html += '<td>'+ n.owner +'</td>';
					html += '<td>'+ n.startDate +'</td>';
					html += '<td>'+ n.endDate +'</td>';
					html += '</tr>';
				});

				$("#activityBody").html(html);

				//计算总页数
				var totalPages = data.total % pageSize === 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;

				//数据处理完毕后，结合分页插件，对前端展现分页信息
				$("#activityPage").bs_pagination({
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
	<input type="hidden" id="hidden-startDate" />
	<input type="hidden" id="hidden-endDate" />

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
									<!--<option>zhangsan</option>
										<option>lisi</option>
										<option>wangwu</option>-->
									<!--
										动态拼接用户下拉选项
									-->
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startDate">
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endDate">
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<!--
						data-dismiss：关闭模态窗口
					-->
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="saveBtn" class="btn btn-primary">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id">

						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
									<!--<option>zhangsan</option>
									<option>lisi</option>
									<option>wangwu</option>-->
									<!--
										动态拼接用户下拉选项
									-->
								</select>
							</div>
                            <label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-startDate">
							</div>
							<label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-endDate">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<!--
									关于文本域textarea：
										(1)一定要以标签对的形式呈现，正常状态下标签对要紧挨着
										(2)属于表单元素范畴，所有对textarea的取值和赋值操作统一使用val()而不是html()方法
								-->
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
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
				<h3>市场活动列表</h3>
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
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<!--
						data-toggle="modal"：表示触发该按钮将要打开一个模态窗口
						data-target="#createActivityModal"：表示要打开哪个模态窗口
						问题：没有办法对按钮的功能进行扩充，所以不能写死，需要写js代码来动态操作
					-->
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
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
						<!--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>-->
						<!--

							动态拼接分页查询结果

						-->
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage">

				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>