<%@ page import="com.powerwolf.settings.domain.DicValue" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.powerwolf.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8"%>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
	request.getServerPort() + request.getContextPath() + "/";

	//获取字典类型为stage的字典值列表
	List<DicValue> dicValueList = (List<DicValue>) application.getAttribute("stage");

	//阶段和可能性之间的对应关系
	Map<String, String> pMap = (Map<String, String>) application.getAttribute("possibility");
	Set<String> set = pMap.keySet();

	//准备前面正常阶段和后面丢失阶段的分界点下标
	int index = -1;
	for(int i = 0; i < dicValueList.size(); i++){
		String stage = dicValueList.get(i).getValue();
		if("0".equals(pMap.get(stage))){
			//找到分界点
			index = i;
			break;
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});
		
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });


		//展现交易历史列表
		showTranHistoryList();

	});


	//页面加载完毕后，展现交易历史列表
	function showTranHistoryList() {
		$.ajax({
			url: "workbench/transaction/getTranHistoryList.do",
			data: {
				"tranId": "${tran.id}"
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				/*
					data:
						[{交易历史1}, {交易历史2}, ...]
				 */
				var html = "";
				$.each(data, function (i, n) {
					html += "<tr>";
					html += "<td>"+ n.stage +"</td>";
					html += "<td>"+ n.money +"</td>";
					html += "<td>"+ n.possibility +"</td>";
					html += "<td>"+ n.expectedDate +"</td>";
					html += "<td>"+ n.createTime +"</td>";
					html += "<td>"+ n.createBy +"</td>";
					html += "</tr>";
				});
				$("#tranHistoryBody").html(html);
			}
		})
	}


	/*
		改变交易阶段
		stage：需要变更到的目标阶段
		i：目标阶段对应的下标
	 */
	function changeStage(stage, i) {
		$.ajax({
			url: "workbench/transaction/changeStage.do",
			data: {
				"id": "${tran.id}",
				"stage": stage,
				"money": "${tran.money}",
				"expectedDate": "${tran.expectedDate}"
			},
			type: "post",
			dataType: "json",
			success: function (data) {
				/*
					data
						{"success":true/false, "tran":{交易}, "possibility":xx}
				 */
				if(data.success){
					//1.变更成功，在详细信息页上刷新阶段、可能性、修改人、修改信息
					$("#stage").html(data.tran.stage);
					$("#possibility").html(data.possibility);
					$("#editBy").html(data.tran.editBy);
					$("#editTime").html(data.tran.editTime);

					//2.刷新交易历史列表
					showTranHistoryList();

					//3.将所有的阶段图标重新判断，重新赋予样式及颜色
					changeIcon(stage, i);
				}else{
					alert("变更阶段失败");
				}
			}
		})
	}


	//改变图标，currStage和currIndex都是string类型
	function changeIcon(currStage, currIndex) {
		var currPossibility = $("#possibility").html();	//当前阶段可能性
		var point = "<%=index%>";	//前面正常阶段和后面丢失阶段的分界点下标

		if(currPossibility === "0"){
			//当前阶段的可能性为0
			for(var i = 0; i < point; i++){
				//黑圈
				var $span = $("#" + i);
				//移除原有样式
				$span.removeClass();
				//添加新样式
				$span.addClass("glyphicon glyphicon-record mystage");
				//为新样式赋予颜色
				$span.css("color", "#000000");
			}
			for(var i = point; i < <%=dicValueList.size()%>; i++){
				if(i == currIndex){
					//是当前阶段，红叉
					var $span = $("#" + i);
					$span.removeClass();
					$span.addClass("glyphicon glyphicon-remove mystage");
					$span.css("color", "#FF0000");
				}else{
					//不是当前阶段，黑叉
					var $span = $("#" + i);
					$span.removeClass();
					$span.addClass("glyphicon glyphicon-remove mystage");
					$span.css("color", "#000000");
				}
			}
		}else{
			//当前阶段的可能性不为0
			for(var i = 0; i < point; i++){
				if(i == currIndex){
					//是当前阶段，绿色标记
					var $span = $("#" + i);
					$span.removeClass();
					$span.addClass("glyphicon glyphicon-map-marker mystage");
					$span.css("color", "#90F790");
				}else if(i < currIndex){
					//小于当前阶段，绿圈
					var $span = $("#" + i);
					$span.removeClass();
					$span.addClass("glyphicon glyphicon-ok-circle mystage");
					$span.css("color", "#90F790");
				}else{
					//大于当前阶段，黑圈
					var $span = $("#" + i);
					$span.removeClass();
					$span.addClass("glyphicon glyphicon-record mystage");
					$span.css("color", "#000000");
				}
			}
			for(var i = point; i < <%=dicValueList.size()%>; i++){
				//黑叉
				var $span = $("#" + i);
				$span.removeClass();
				$span.addClass("glyphicon glyphicon-remove mystage");
				$span.css("color", "#000000");
			}
		}
	}

	
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${tran.customerId}-${tran.name} <small>${tran.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='edit.jsp';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

        <%
            //取得当前阶段和可能性
            Tran tran = (Tran) request.getAttribute("tran");
            String currStage = tran.getStage();
            String currPossibility = pMap.get(currStage);
            if("0".equals(currPossibility)){
                //当前阶段的可能性为0
                for(int i = 0; i < dicValueList.size(); i++){
                    DicValue dicValue = dicValueList.get(i);
                    String stage = dicValue.getValue();
                    String possibility = pMap.get(stage);
                    if("0".equals(possibility)){
                        //说明是后两个阶段
                        if(stage.equals(currStage)){
                            //是当前阶段，红叉
		%>
			<span id="<%=i%>" onclick="changeStage('<%=stage%>', '<%=i%>')"
				  class="glyphicon glyphicon-remove mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: red;"></span>
			-----------
		<%
                        }else{
                            //不是当前阶段，黑叉
		%>
			<span id="<%=i%>" onclick="changeStage('<%=stage%>', '<%=i%>')"
				  class="glyphicon glyphicon-remove mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------
		<%
                        }
                    }else{
                        //说明是前七个阶段，黑圈
		%>
			<span id="<%=i%>" onclick="changeStage('<%=stage%>', '<%=i%>')"
				  class="glyphicon glyphicon-record mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------
		<%
                    }
                }
            }else{
            	//当前阶段可能性不为0
				int currIndex = 0;
				for(int i = 0; i < dicValueList.size(); i++){
					DicValue dicValue = dicValueList.get(i);
					String stage = dicValue.getValue();
					if(stage.equals(currStage)){
						//找到当前阶段
						currIndex = i;
						break;
					}
				}
				for(int i = 0; i < dicValueList.size(); i++){
					DicValue dicValue = dicValueList.get(i);
					String stage = dicValue.getValue();
					String possibility = pMap.get(stage);
					if("0".equals(possibility)){
						//说明是后两个阶段，黑叉
		%>
			<span id="<%=i%>" onclick="changeStage('<%=stage%>', '<%=i%>')"
				  class="glyphicon glyphicon-remove mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------
		<%
					}else{
						//说明是前七个阶段
						if(currIndex == i){
							//如果是当前阶段，绿色标记
		%>
			<span id="<%=i%>" onclick="changeStage('<%=stage%>', '<%=i%>')"
				  class="glyphicon glyphicon-map-marker mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
			-----------
		<%
						}else if(currIndex > i){
							//小于当前阶段，绿圈
		%>
			<span id="<%=i%>" onclick="changeStage('<%=stage%>', '<%=i%>')"
				  class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
			-----------
		<%
						}else{
							//大于当前阶段，黑圈
		%>
			<span id="<%=i%>" onclick="changeStage('<%=stage%>', '<%=i%>')"
				  class="glyphicon glyphicon-record mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------
		<%
						}
					}
				}
			}
        %>
		<span class="closingDate">${tran.expectedDate}</span>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${tran.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${possibility}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${tran.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${tran.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">${tran.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${tran.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${tran.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.nextContactTime}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="tranHistoryBody">
						<!--<tr>
							<td>资质审查</td>
							<td>5,000</td>
							<td>10</td>
							<td>2017-02-07</td>
							<td>2016-10-10 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>需求分析</td>
							<td>5,000</td>
							<td>20</td>
							<td>2017-02-07</td>
							<td>2016-10-20 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>谈判/复审</td>
							<td>5,000</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>2017-02-09 10:10:10</td>
							<td>zhangsan</td>
						</tr>-->
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>