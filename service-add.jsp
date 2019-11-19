<%@ page contentType="text/html;charset=UTF-8" language="java" %>

    <head>
        <title>服务创建</title>
        <meta http-equiv="content-type" content="text/html;charset=UTF-8">
        <%@ include file="../../../../common/base.jsp"%>
            <link rel="shortcut icon" href="#" />
            <link rel="stylesheet" type="text/css" href="${resContextPath}/plugin/jquery/jquery-ui-1.12.1/jquery-ui.min.css">
            <link rel="stylesheet" type="text/css" href="${resContextPath}/css/model/console/bcm/service/service.css">
            <link rel="stylesheet" type="text/css" href="${resContextPath}/css/dashboard.css">
            <link rel="stylesheet" type="text/css" href="${resContextPath}/css/search-input.css">
    </head>

    <body>
        <div class="page-container">
            <%@ include file="../../../../common/navigation.jsp"%>
                <div class="bcloud-rel">
                    <div class="page-content page-mg">
                        <div class="page-wrap bcloud-all">
                            <div class="bcloud-header">
                                <div class="bcloud-header-title">填写服务信息</div>
                            </div>
                            <div class="bcloud-content">
                                <div class="row">
                                    <form id="serviceBaseForm">
                                        <div class="form-group col-md-12 col-lg-12">
                                            <label class="col-md-12 col-lg-12">服务名称</label>
                                            <div class="col-md-5 col-lg-5">
                                                <input type="text" class="form-control input-lg" placeholder="请输入服务名称" name="serviceName" autocomplete="off">
                                            </div>
                                        </div>
                                        <div class="form-group col-md-12 col-lg-12">
                                            <label class="col-md-12 col-lg-12">服务描述</label>
                                            <div class="col-md-5 col-lg-5">
                                                <input type="text" class="form-control input-lg" placeholder="为服务编辑一个简单的介绍" name="description" autocomplete="off">
                                            </div>
                                        </div>
                                        <div class="col-md-12 col-lg-12">
                                            <label class="col-md-12 col-lg-12">选择镜像</label>
                                            <div class="form-group col-md-3 col-lg-3 config-group ui-widget">
                                                <input type="text" class="form-control input-lg" name="imageName" id="imageName" placeholder="请输入镜像名称搜索" required>
                                            </div>
                                            <div class="form-group col-md-2 col-lg-2">
                                                <select name="imageVersion" class="form-control selectpicker" id="imageVersion" required>
                                                </select>
                                            </div>
                                        </div>
                                        <!-- <div class="col-md-12 col-lg-12">
                                            <label class="col-md-12 col-lg-12">选择镜像</label>
                                            <div class="form-group col-md-3 col-lg-3 combo-search-input">
                                            <div class="config-group combo-input-wrap">
                                                <div class="combo-input">
                                                    <input type="text" class="forShowInput form-control input-lg" name="imageName" placeholder="请输入" disabled="true" value="jdk">
                                                    <input type="text" class="subInput form-control" style="display: none;">
                                                </div>
                                                <dl class="combo-menu static-menu">
                                                    <dd combo-value="" class="search-tips combo-item">直接选择或输入内容</dd>
                                                    <dd combo-value="8080" class="combo-item">
                                                        <span class="search-type">公有</span>
                                                        <span class="search-text combo-show-text">aaa</span>
                                                    </dd>
                                                    <dd combo-value="8081" class="combo-item">
                                                        <span class="search-type" style="color: #0090f4">私有</span>
                                                        <span class="search-text combo-show-text">centos</span>
                                                    </dd>
                                                    <dd combo-value="8082" class="combo-item">
                                                        <span class="search-type">公有</span>
                                                        <span class="search-text combo-show-text">tomcat</span>
                                                    </dd>
                                                    <dd combo-value="8083" class="combo-item">
                                                        <span class="search-type" style="color: #0090f4">私有</span>
                                                        <span class="search-text combo-show-text">jdk</span>
                                                    </dd>
                                                </dl>
                                            </div>
                                        </div>
                                            <div class="form-group col-md-2 col-lg-2">
                                                <select name="imageVersion" class="form-control selectpicker" id="imageVersion" required>
                                                    <option value="">暂无数据</option>
                                                </select>
                                            </div>
                                        </div> -->
                                        <div class="form-group col-md-12 col-lg-12">
                                            <label class="col-md-12 col-lg-12">单实例CPU</label>
                                            <div class="col-md-4 col-lg-4" style="padding-right: 25px">
                                                <div id="slider-cpu" style="margin-top: 15px;">
                                                    <span class="default-block ">每个实例的CPU数量</span>
                                                </div>
                                            </div>
                                            <div class="col-md-1 col-lg-1 quota-unit">
                                                <span class="col-md-6 col-lg-6" id="cpu"></span>
                                                <span class="col-md-6 col-lg-6">个</span>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-12 col-lg-12">
                                            <label class="col-md-12 col-lg-12">单实例内存</label>
                                            <div class="col-md-4 col-lg-4" style="padding-right: 25px">
                                                <div id="slider-memory" style="margin-top: 15px;">
                                                    <span class="default-block ">每个实例的内存数量</span>
                                                </div>
                                            </div>
                                            <div class="col-md-1 col-lg-1 quota-unit">
                                                <span class="col-md-6 col-lg-6" id="memory"></span>
                                                <span class="col-md-6 col-lg-6">个</span>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-12 col-lg-12">
                                            <label class="col-md-12 col-lg-12">实例数量</label>
                                            <div class="col-md-2 col-lg-2">
                                                <div class="input-group service-input-group">
                                                    <span class="input-group-btn">
                                                        <button class="btn btn-bcloud-gray btn-lg" type="button" id="reduceInstance">
                                                            <span class="minus-icon"></span>
                                                        </button>
                                                    </span>
                                                    <input type="text" class="form-control input-lg" value=1 name="instance" id="instance" style="padding-right: 15px;">
                                                    <span class="input-group-btn">
                                                        <button class="btn btn-bcloud-gray btn-lg" type="button" id="addInstance">
                                                            <span class="plus-icon"></span>
                                                        </button>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="col-md-12 col-lg-12">
                                                <span class="default-block ">设置服务运行的实例数量</span>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <br/>
                        <div class="page-wrap">
                            <div class="bcloud-content">
                                <div class="panel panel-default">
                                    <div class="panel-heading" data-toggle="collapse" href="#collapseParent" id="highLevel">
                                        <div class="panel-title">
                                            <img src="${resContextPath}/img/icon/plus-square-fill.svg">
                                            <span class="label-title">高级配置</span>
                                        </div>
                                    </div>
                                </div>
                                <div id="collapseParent" class="panel-collapse collapse">
                                    <div class="panel-group">
                                        <form id="seniorForm">
                                            <!--端口配置-->
                                            <div class="panel panel-default">
                                                <div class="panel-heading" data-toggle="collapse" href="#collapseOne">
                                                    <div class="panel-title">
                                                        <img src="${resContextPath}/img/icon/up.png">
                                                        <span class="label-title">端口配置</span>
                                                    </div>
                                                </div>
                                                <div id="collapseOne" class="panel-collapse collapse">
                                                    <div class="panel-body">
                                                        <div class="input-tip">
                                                            <img src="${resContextPath}/img/icon/warning.svg">
                                                            <span class="tip-msg">配置服务运行时占用的端口，需要至少配置一个，或者服务创建完成后，进入服务下“访问策略”进行配置</span>
                                                        </div>
                                                        <div id="portGroup" class="row">
                                                            <div class="col-md-12 col-lg-12 portItem">
                                                                <div class="form-group col-md-3 col-lg-3 config-group">
                                                                    <label class="col-md-12 col-lg-12">端口</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input type="number" class="form-control input-lg port" name="port" placeholder="端口">
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-3 col-lg-3 config-group">
                                                                    <label class="col-md-12 col-lg-12">协议</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <select class="form-control input-lg" name="protocol">
                                                                            <option value="TCP">TCP</option>
                                                                            <option value="UDP">UDP</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-1 col-lg-1 delete-item deleteItem">删除</div>
                                                            </div>
                                                        </div>
                                                        <div class="add-config" id="addPort">
                                                            <i class="fa fa-plus"></i>
                                                            <span>添加端口</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <!--环境变量-->
                                            <div class="panel panel-default">
                                                <div class="panel-heading" data-toggle="collapse" href="#collapseTwo">
                                                    <div class="panel-title">
                                                        <img src="${resContextPath}/img/icon/up.png" />
                                                        <span class="label-title">环境变量</span>
                                                    </div>
                                                </div>
                                                <div id="collapseTwo" class="panel-collapse collapse">
                                                    <div class="panel-body">
                                                        <div class="input-tip">
                                                            <img src="${resContextPath}/img/icon/warning.svg">
                                                            <span class="tip-msg">配置服务运行时依赖的环境变量参数</span>
                                                        </div>
                                                        <div id="envGroup" class="row">
                                                            <div class="col-md-12 col-lg-12 envItem">
                                                                <div class="col-md-4 col-lg-4">
                                                                    <div class="form-group col-md-9 col-lg-9">
                                                                        <label class="col-md-12 col-lg-12">变量名</label>
                                                                        <div class="col-md-12 col-lg-12">
                                                                            <input class="form-control input-lg envKey" type="text" name="envKey">
                                                                        </div>
                                                                    </div>
                                                                    <div class="form-group col-md-3 col-lg-3 env-colon">：</div>
                                                                </div>
                                                                <div class="form-group col-md-3 col-lg-3" style="padding-right: 16px">
                                                                    <label class="col-md-12 col-lg-12">变量值</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input class="form-control input-lg envValue" type="text" name="envValue">
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-1 col-lg-1 delete-item deleteItem">删除</div>
                                                            </div>
                                                        </div>
                                                        <div class="add-config" style="cursor: default;">
                                                            <div id="addEnv" style="float: left;cursor: pointer">
                                                                <i class="fa fa-plus"></i>
                                                                <span>添加环境变量</span>
                                                            </div>
                                                            <div class="import-config">
                                                                或
                                                                <span id="selectTemplates">导入</span>变量模板
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <!--配置文件-->
                                            <div class="panel panel-default">
                                                <div class="panel-heading" data-toggle="collapse" href="#collapseThree">
                                                    <div class="panel-title">
                                                        <img src="${resContextPath}/img/icon/up.png" />
                                                        <span class="label-title">配置文件</span>
                                                    </div>
                                                </div>
                                                <div id="collapseThree" class="panel-collapse collapse">
                                                    <div class="panel-body">
                                                        <div class="input-tip">
                                                            <img src="${resContextPath}/img/icon/warning.svg">
                                                            <span class="tip-msg">配置服务运行时依赖的外部配置文件，如xml、json、properties等常用配置文件</span>
                                                        </div>
                                                        <div id="configMapGroup" class="row">
                                                            <!-- <div class="col-md-12 col-lg-12 configMapItem">
                                                                <div class="form-group col-md-3 col-lg-3">
                                                                    <label class="col-md-12 col-lg-12">模板名称</label>
                                                                    <div class="col-md-12 col-lg-12 ui-widget">
                                                                        <input type="text" class="form-control input-lg" name="configMap" placeholder="请选择模板">
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-2 col-lg-2" style="text-align: center">
                                                                    <label class="col-md-12 col-lg-12">文件数量</label>
                                                                    <label class="col-md-12 col-lg-12 config-num">3</label>
                                                                </div>
                                                                <div class="form-group col-md-3 col-lg-3" style="padding-right: 16px">
                                                                    <label class="col-md-12 col-lg-12">挂载路径</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input class="form-control input-lg" name="configMapPath" value="/" placeholder="/">
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-1 col-lg-1 delete-item deleteItem">删除</div>
                                                            </div> -->
                                                        </div>
                                                        <div class="add-config" id="addConfigMap">
                                                            <i class="fa fa-plus"></i>
                                                            <span>添加配置文件</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <!--存储-->
                                            <div class="panel panel-default">
                                                <div class="panel-heading" data-toggle="collapse" href="#collapseFour">
                                                    <div class="panel-title">
                                                        <img src="${resContextPath}/img/icon/up.png" />
                                                        <span class="label-title">存储</span>
                                                    </div>
                                                </div>
                                                <div id="collapseFour" class="panel-collapse collapse">
                                                    <div class="panel-body">
                                                        <div id="fileStorageGroup" class="row">
                                                            <!-- <div class="col-md-12 col-lg-12 fileStorageItem">
                                                                <div class="form-group col-md-3 col-lg-3">
                                                                    <label class="col-md-12 col-lg-12">存储名称</label>
                                                                    <div class="col-md-12 col-lg-12 ui-widget">
                                                                        <select class="form-control selectpicker" name="fileStorageName">
                                                                            <option value=''>请选择存储</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-2 col-lg-2" style="text-align: center">
                                                                    <label class="col-md-12 col-lg-12">存储大小</label>
                                                                    <label class="col-md-12 col-lg-12 config-num">3G</label>
                                                                </div>
                                                                <div class="form-group col-md-3 col-lg-3" style="padding-right: 16px">
                                                                    <label class="col-md-12 col-lg-12">挂载目录</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input class="form-control input-lg" name="fileStoragePath" value="/" placeholder="/">
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-1 col-lg-1 delete-item deleteItem">删除</div>
                                                            </div> -->
                                                        </div>
                                                        <div class="add-config" style="cursor: default;">
                                                            <div id="addFileStorage" style="float: left;cursor: pointer">
                                                                <i class="fa fa-plus"></i>
                                                                <span>添加存储</span>
                                                            </div>
                                                            <div class="import-config">
                                                                找不到存储？请先到“
                                                                <span>
                                                                    <a href="${pageContext.request.contextPath}/bcos/v1/storage/file/page">存储</a>
                                                                </span>”菜单下，创建一个新的存储
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </form>
                                        <!--健康监测-->
                                        <div class="panel panel-default" style="margin-top: 1px;">
                                            <div class="panel-heading" data-toggle="collapse" href="#collapseFive">
                                                <div class="panel-title">
                                                    <img src="${resContextPath}/img/icon/up.png" />
                                                    <span class="label-title">服务监测分析 </span>
                                                </div>
                                            </div>
                                            <div id="collapseFive" class="panel-collapse collapse">
                                                <div class="panel-body">
                                                    <!-- 启动监测 -->
                                                    <form id="startHealthCheckForm">
                                                        <div class="health-check-heading">
                                                            <div id="start-switch" class="bcloud-switch bcloud-switch-left" style="float: left;display: block">
                                                                <div class="bcloud-switch-slider bcloud-switch-animate"></div>
                                                            </div>
                                                            <span class="health-check-title">启动监测</span>
                                                        </div>
                                                        <div class="startHealthCheckForm">
                                                            <input name="probe" type="hidden" value="2" />
                                                            <div class="col-md-12 col-lg-12">
                                                                <div class="form-group col-md-4 col-lg-4 config-group">
                                                                    <label class="col-md-12 col-lg-12">探针协议</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <select class="form-control selectpicker" name="proType">
                                                                            <option value="http">http</option>
                                                                            <option value="tcp">tcp</option>
                                                                            <option value="exec">exec</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-4 col-lg-4 config-group http">
                                                                    <label class="col-md-12 col-lg-12">监测端口</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input type="number" class="form-control input-lg" name="httpPort" required>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-4 col-lg-4 config-group tcp" style="display: none">
                                                                    <label class="col-md-12 col-lg-12">监测端口</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input type="number" class="form-control input-lg" name="tcpPort" required>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-12 col-lg-12 config-group http">
                                                                <label class="col-md-12 col-lg-12">监测路径</label>
                                                                <div class="col-md-8 col-lg-8">
                                                                    <input type="text" class="form-control input-lg" placeholder="/health" name="path" required autocomplete="off">
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-12 col-lg-12 config-group exec" style="display: none">
                                                                <label class="col-md-12 col-lg-12">命令</label>
                                                                <div class="col-md-8 col-lg-8">
                                                                    <textarea class="form-control execVal" name="exec" rows="4" required style="height: auto;"></textarea>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-12 col-lg-12 http">
                                                                <div class="form-group col-md-8 col-lg-8">
                                                                    <label class="col-md-12 col-lg-12">HTTP头</label>
                                                                    <div class="col-md-6 col-lg-6 config-group">
                                                                        <input type="text" class="form-control input-lg" name="httpHeadeName" placeholder="name">
                                                                    </div>
                                                                    <div class="col-md-6 col-lg-6 config-group">
                                                                        <input type="text" class="form-control input-lg" name="httpHeadeValue" placeholder="value">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-12 col-lg-12">
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">初始化等候时间</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="initialDelay" min=0 value=600 required>
                                                                            <span class="input-group-btn">秒</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">间隔时间</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="periodDetction" min=1 value=10 required>
                                                                            <span class="input-group-btn">秒</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">超时时间</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="timeoutDetction" min=0 value=5 required>
                                                                            <span class="input-group-btn">秒</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">连接成功次数</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="successThreshold" min=1 value=1 required>
                                                                            <span class="input-group-btn">次</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </form>
                                                    <!-- 运行监测 -->
                                                    <form id="runningHealthCheckForm">
                                                        <div class="health-check-heading">
                                                            <div id="running-switch" class="bcloud-switch bcloud-switch-left" style="float: left;display: block">
                                                                <div class="bcloud-switch-slider bcloud-switch-animate"></div>
                                                            </div>
                                                            <span class="health-check-title">启动监测</span>
                                                        </div>
                                                        <div class="runningHealthCheckForm">
                                                            <input name="probe" type="hidden" value="1" />
                                                            <div class="col-md-12 col-lg-12">
                                                                <div class="form-group col-md-4 col-lg-4 config-group">
                                                                    <label class="col-md-12 col-lg-12">探针协议</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <select class="form-control selectpicker" name="proType">
                                                                            <option value="http">http</option>
                                                                            <option value="tcp">tcp</option>
                                                                            <option value="exec">exec</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-4 col-lg-4 config-group http">
                                                                    <label class="col-md-12 col-lg-12">监测端口</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input type="number" class="form-control input-lg" name="httpPort" required>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-4 col-lg-4 config-group tcp" style="display: none">
                                                                    <label class="col-md-12 col-lg-12">监测端口</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <input type="number" class="form-control input-lg" name="tcpPort" required>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-12 col-lg-12 config-group http">
                                                                <label class="col-md-12 col-lg-12">监测路径</label>
                                                                <div class="col-md-8 col-lg-8">
                                                                    <input type="text" class="form-control input-lg" placeholder="/health" name="path" required autocomplete="off">
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-12 col-lg-12 config-group exec" style="display: none">
                                                                <label class="col-md-12 col-lg-12">命令</label>
                                                                <div class="col-md-8 col-lg-8">
                                                                    <textarea class="form-control execVal" name="exec" rows="4" required style="height: auto;"></textarea>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-12 col-lg-12 http">
                                                                <div class="form-group col-md-8 col-lg-8">
                                                                    <label class="col-md-12 col-lg-12">HTTP头</label>
                                                                    <div class="col-md-6 col-lg-6 config-group">
                                                                        <input type="text" class="form-control input-lg" name="httpHeadeName" placeholder="name">
                                                                    </div>
                                                                    <div class="col-md-6 col-lg-6 config-group">
                                                                        <input type="text" class="form-control input-lg" name="httpHeadeValue" placeholder="value">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-12 col-lg-12">
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">初始化等候时间</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="initialDelay" min=0 value=600 required>
                                                                            <span class="input-group-btn">秒</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">间隔时间</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="periodDetction" min=1 value=10 required>
                                                                            <span class="input-group-btn">秒</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">超时时间</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="timeoutDetction" min=0 value=5 required>
                                                                            <span class="input-group-btn">秒</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-2 col-lg-2 config-group">
                                                                    <label class="col-md-12 col-lg-12">连接成功次数</label>
                                                                    <div class="col-md-12 col-lg-12">
                                                                        <div class="input-group bcloud-input-info">
                                                                            <input type="number" class="form-control input-lg" name="successThreshold" min=1 value=1 required>
                                                                            <span class="input-group-btn">次</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </form>
                                                    <div class="health-check-heading" style="margin-top: 30px">
                                                        <div id="apm-switch" class="bcloud-switch bcloud-switch-right" style="float: left;display: block">
                                                            <div class="bcloud-switch-slider bcloud-switch-animate"></div>
                                                        </div>
                                                        <span class="health-check-title">APM应用性能分析</span>
                                                        <span class="health-check-info">建议开启。关闭后，系统将无法提供拓扑图的展示</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <!--启动命令-->
                                        <div class="panel panel-default">
                                            <div class="panel-heading" data-toggle="collapse" href="#collapseSix">
                                                <div class="panel-title">
                                                    <img src="${resContextPath}/img/icon/up.png" />
                                                    <span class="label-title">启动命令</span>
                                                </div>
                                            </div>
                                            <div id="collapseSix" class="panel-collapse collapse">
                                                <div class="panel-body">
                                                    <form>
                                                        <div class="form-group col-md-12 col-lg-12">
                                                            <label class="col-md-12 col-lg-12">启动命令</label>
                                                            <div class="col-md-5 col-lg-5">
                                                                <input type="text" class="form-control input-lg" placeholder="请输入启动命令" name="cmd">
                                                            </div>
                                                            <div class="col-md-12 col-lg-12">
                                                                <span class="default-block ">
                                                                    <a class="create-block" style="margin-left: 0;margin-right: 10px;">点击查看</a>启动命令输入说明</span>
                                                            </div>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="right-content bcloud-gray">
                        <div class="bcloud-header">
                            <div class="bcloud-header-title">配额信息</div>
                        </div>
                        <div class="bcloud-content item-bold">
                            <div class="bcloud-item">
                                <div class="item-title">CPU</div>
                                <div class="item-content">
                                    <span id="usedCpu">1</span> /
                                    <span id="allCpu">0</span> 个</div>
                                <br/>
                                <span class="default-block ">本次消费数量 / 配额剩余数量</span>
                            </div>
                            <hr/>
                            <div class="bcloud-item">
                                <div class="item-title">内存</div>
                                <div class="item-content">
                                    <span id="usedMemory">1</span> /
                                    <span id="allMemory">0</span> GB</div>
                                <br/>
                                <span class="default-block ">本次消费数量 / 配额剩余数量</span>
                                <br/>
                                <span class="info-block" id="quotaTips">
                                    <img src="${resContextPath}/img/icon/warning.svg"> 您的配额不足
                                    <a href="" id="quotaAddress">申请配额</a>
                                </span>
                            </div>
                            <button type="button" id="createService" class="btn btn-bcloud-blue disabled btn-lg btn-block" onclick="createService()"
                                disabled="disabled">创建</button>
                        </div>
                    </div>
                </div>
        </div>

        <div id="template" style="display: none;">
            <div class="row">
                <form>
                    <div class="form-group col-md-12 col-lg-12">
                        <div id="envTemplateNameSearch" class="input-group bcloud-input-search col-md-12 col-lg-12">
                            <input type="text" class="form-control input-lg" placeholder="输入服务名称或描述搜索">
                            <span class="input-group-btn">
                                <button class="btn btn-bcloud-gray" type="button">
                                    <i class="fa fa-search"></i>
                                </button>
                            </span>
                        </div>
                    </div>
                    <div id="envList"></div>
                </form>
            </div>
        </div>
    </body>
    <script src="${resContextPath}/plugin/jquery/jquery-ui-1.12.1/jquery-ui.min.js"></script>
    <script src="${resContextPath}/js/model/console/bcm/service/service-common.js"></script>
    <script src="${resContextPath}/js/model/console/bcm/service/validator.js"></script>
    <script src="${resContextPath}/js/model/console/bcm/service/service-add.js"></script>
    <script src="${resContextPath}/js/common/search-input.js"></script>
    <script type="text/javascript">
        var resourceData = getMaxResource();
        $("#slider-cpu").slider({
            range: "min",
            value: 1,
            min: 1,
            max: resourceData.cpuMax,
            slide: function (event, ui) {
                $("#cpu").text(ui.value);
                $("#usedCpu").text(ui.value * $("#instance").val());
                chenckQuota();
            }
        });
        $("#cpu").html($("#slider-cpu").slider("value"));
        $("#usedCpu").text($("#cpu").text() * $("#instance").val());
        $("#slider-memory").slider({
            range: "min",
            value: 1,
            min: 1,
            max: resourceData.memoryMax,
            slide: function (event, ui) {
                $("#memory").text(ui.value);
                $("#usedMemory").text(ui.value * $("#instance").val());
                chenckQuota();
            }
        });
        $("#memory").text($("#slider-memory").slider("value"));
        $("#usedMemory").text($("#memory").text() * $("#instance").val());
        chenckQuota();
    </script>

    </html>