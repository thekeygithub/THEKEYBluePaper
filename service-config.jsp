<%@ page contentType="text/html;charset=UTF-8" language="java" %>

    <head>
        <title>配置文件</title>
        <meta http-equiv="content-type" content="text/html;charset=UTF-8">
        <%@ include file="../../../../common/base.jsp"%>
            <link rel="shortcut icon" href="#" />
            <link rel="stylesheet" type="text/css" href="${resContextPath}/css/model/console/bcm/service/service.css">
    </head>

    <body>
        <div class="page-container">
            <%@ include file="../../../../common/navigation.jsp"%>
                <div class="page-content">
                    <div class="page-wrap">
                        <div class="bcloud-header">
                            <div class="bcloud-header-title">配置文件</div>
                            <div class="bcloud-header-operation pull-right">
                                <form class="form-inline">
                                    <div class="input-group bcloud-input-search">
                                        <input type="text" class="form-control" id="templateNameSearch" placeholder="输入关键字搜索" autocomplete="off">
                                        <span class="input-group-btn">
                                            <button class="btn btn-bcloud-gray" id="searchButton" type="button">
                                                <i class="fa fa-search"></i>
                                            </button>
                                        </span>
                                    </div>
                                </form>
                                <div class="bcloud-btn-operation">
                                    <a class="btn btn-link btn-xs" href="${pageContext.request.contextPath}/bcos/v1/app/config/create/page" id="add-config-btn"
                                        style="display: none">
                                        <img src="${resContextPath}/img/icon/plus-square-s-o.svg">新增
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div class="bcloud-content">
                            <div class="row row-block" id="configList">
                            </div>
                        </div>
                    </div>
                </div>
        </div>

        <%--确认框--%>
            <div class="modal fade bs-example-modal-sm" id="deleteConfirmModal" tabindex="-1" role="dialog">
                <div class="modal-dialog modal-sm">
                    <div class="modal-content bcloud-confirm-content">
                        <div class="modal-header bcloud-confirm-header">
                            删除信息
                        </div>
                        <div class="modal-body bcloud-confirm-body">
                            请问是否删除该模板？
                            <input type="hidden" name="deleteId" />
                        </div>
                        <div class="modal-footer bcloud-confirm-footer">
                            <button class="btn btn-bcloud-blue active" onclick="deleteConfirm()">确定</button>
                            <button class="btn btn-bcloud-white" data-dismiss="modal">取消</button>
                        </div>
                    </div>
                </div>
            </div>
    </body>
    <script src="${resContextPath}/js/model/console/bcm/service/service-config.js"></script>

    </html>