<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
            request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

    <script>
        $(function () {
            //使login.jsp始终在顶层窗口打开
            if(window.top !== window){
                window.top.location = window.location;
            }

            //将用户文本框内容清空
            $("#loginAct").val("");

            //页面加载完毕后，文本框自动获得焦点
            $("#loginAct").focus();

            //为登录按钮绑定事件
            $(".btn").click(function () {
                login();
            });

            //为当前窗口绑定敲键盘事件,event：取得接收参数
            $(window).keydown(function (event) {
                //如果是回车键
                if(event.keyCode === 13){
                    login();
                }
            });
        });

        //登陆操作回调函数
        function login() {
            //取得账号密码，并去掉左右空格
            var loginAct = $.trim($("#loginAct").val());
            var loginPwd = $.trim($("#loginPwd").val());

            if(loginAct === "" || loginPwd === ""){
                //账号或密码为空
                $("#msg").html("账号密码不能为空");
                return false;
            }

            //后台验证登录
            $.ajax({
                url: "user/login.do",
                data: {
                    "loginAct": loginAct,
                    "loginPwd": loginPwd
                },
                type: "post",
                dataType: "json",
                success: function (data) {
                    /*
                        data:
                            {"success":true/false,"mag":xxx}
                     */
                    if(data.success){
                        //登录成功，跳转页面
                        window.location.href = "workbench/index.jsp";
                    }else{
                        //登录失败，显示错误提示信息
                        $("#msg").html(data.msg);
                    }
                }
            })
        }
    </script>
</head>
<body>
    <div style="position: absolute; top: 0px; left: 0px; width: 60%;">
        <img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
    </div>
    <div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
        <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">
            CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
    </div>

    <div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
        <div style="position: absolute; top: 0px; right: 60px;">
            <div class="page-header">
                <h1>登录</h1>
            </div>
            <form action="workbench/index.jsp" class="form-horizontal" role="form">
                <div class="form-group form-group-lg">
                    <div style="width: 350px;">
                        <input class="form-control" type="text" placeholder="用户名" id="loginAct">
                    </div>
                    <div style="width: 350px; position: relative;top: 20px;">
                        <input class="form-control" type="password" placeholder="密码" id="loginPwd">
                    </div>
                    <div class="checkbox" style="position: relative;top: 30px; left: 10px;">

                        <span id="msg" style="color: red"></span>

                    </div>
                    <button type="button" class="btn btn-primary btn-lg btn-block"
                            style="width: 350px; position: relative;top: 45px;">登录
                    </button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>