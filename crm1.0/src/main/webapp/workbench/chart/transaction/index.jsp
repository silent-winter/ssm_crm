<%@ page contentType="text/html;charset=UTF-8" language="java"
         pageEncoding="utf-8" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
            request.getServerPort() + request.getContextPath() + "/";
    /*
        根据交易表中的不同阶段的数量进行一个统计，形成漏斗图 

        将统计出来的阶段数量较多的往上排列，数量较少的往下排列
        例：
            01资质审查  10条
            02需求分析  85条
            03价值建议  3条
            ...
            07成交  100条
     */
%>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="utf-8">
    <title>交易统计图</title>
    <!--引入echarts-->
    <script type="text/javascript" src="ECharts/echarts.min.js"></script>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>

    <script>

        $(function () {

            //页面加载完毕后，绘制统计图标
            getCharts();

        });


        function getCharts() {
            $.ajax({
                url: "workbench/transaction/getCharts.do",
                type: "get",
                dataType: "json",
                success: function (data) {
                    /*
                        data
                            {"total": xxx, dataList:[{value: xxx, name: xxx}, {value: xxx, name: xxx}, ...]}
                     */
                    //基于准备好的dom，初始化echarts实例
                    var myChart = echarts.init(document.getElementById('main'));

                    //指定图表的配置项和数据
                    var option = {
                        title: {
                            text: '漏斗图',
                            subtext: '纯属虚构'
                        },
                        tooltip: {
                            trigger: 'item',
                            formatter: "{a} <br/>{b} : {c}%"
                        },
                        series: [
                            {
                                name:'漏斗图',
                                type:'funnel',
                                left: '10%',
                                top: 60,
                                //x2: 80,
                                bottom: 60,
                                width: '80%',
                                // height: {totalHeight} - y - y2,
                                min: 0,
                                max: data.total,
                                minSize: '0%',
                                maxSize: '100%',
                                sort: 'descending',
                                gap: 2,
                                label: {
                                    show: true,
                                    position: 'inside'
                                },
                                labelLine: {
                                    length: 10,
                                    lineStyle: {
                                        width: 1,
                                        type: 'solid'
                                    }
                                },
                                itemStyle: {
                                    borderColor: '#fff',
                                    borderWidth: 1
                                },
                                emphasis: {
                                    label: {
                                        fontSize: 20
                                    }
                                },
                                data: data.dataList
                            }
                        ]
                    };

                    // 使用刚指定的配置项和数据显示图表。
                    myChart.setOption(option);
                }
            });
        }

    </script>
</head>
<body>
    <!-- 为 ECharts 准备一个具备大小（宽高）的 DOM -->
    <div id="main" style="width: 600px;height:400px;">

    </div>
</body>
</html>
