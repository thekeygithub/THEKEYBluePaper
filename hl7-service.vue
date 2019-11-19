<style scoped>
    @import "hl7-service.less";
</style>
<template>
    <div>
        <Row>
            <Col span="24">
            <Card>
                <h2 slot="title">
                    <Icon type="search" size="28" color="#2D8CF1">
                    </Icon>&nbsp;检索
                </h2>
                <Row>
                    <Col span="4" style="text-align: right; margin-top: 5px">EMPI:</Col>
                    <Col span="13" style="margin-left: 8px">
                    <Input @on-enter="search" type="text" v-model='empiValue' placeholder="请输入EMPI编号..."></Input>
                    <!--<Button type="info" icon="ios-search"  style="width: 180px;" @click="search">检索</Button>-->
                    </Col>
                    <Col span="5">
                    <Button type="info" icon="ios-search" style="width: 180px; margin-left: 10px" @click="search">
                    检索
                    </Button>
                    </Col>
                </Row>
            </Card>
            </Col>
        </Row>
        <Row>
            <Col span="24">
            <Card id=1 style="margin-top: 3px">
                <h2 slot="title">
                    <Icon type="ios-people" size="28" color="#2D8CF1"></Icon>
                    &nbsp;检索相关
                </h2>
                <Tabs type="card" v-model="tabValue" @on-click="initData">
                    <TabPane v-for="tab in tabs" :key="tab.value" :label="tab.label" :name="tab.value">
                        <Table :columns="hlColumns"
                               :data="baseData"
                               border
                               :loading="loading"
                               @on-current-change="revertXml"
                               class="hlTable"
                               :highlight-row="highLight"
                        ></Table>
                        <Page :total="total" show-elevator show-total
                              @on-change="changePage"
                              :page-size="pageSize"
                              style="text-align: right; margin-top: 10px">
                        </Page>
                    </TabPane>
                    <Button slot="extra"
                            style="margin-top: -3px; width: 200px; border-radius: 10px;
                             color: white; background-color: #F4695D; z-index: 1000000"
                            size="small"
                            @click="beginRevert"
                    >
                        <Icon type="ios-download-outline" size="20"></Icon>
                        &nbsp;&nbsp;
                        <span style="font-size: 16px">HL7格式输出</span>
                    </Button>
                </Tabs>
            </Card>
            </Col>
        </Row>
        <Row>
            <div id="xmlDiv" style="background:#eee; margin-top: 3px;">
                <Card :bordered="false">
                    <h2 slot="title">
                        <img src="../../../images/out.png" style="width: 30px; height: 30px">
                        &nbsp;HL7格式输出
                    </h2>
                    <p>文件内容: </p>
                    <xmp>{{ xmlData }}</xmp>
                </Card>
            </div>
        </Row>
    </div>
</template>
<script>
    export default {
        data() {
            return {
                highLight: true,
                loading: true,
                tabs: [
                    {
                        label: '门急诊',
                        value: '门急诊'
                    },
                    {
                        label: '检验',
                        value: '检验'
                    },
                    {
                        label: '检查',
                        value: '检查'
                    },
                    {
                        label: '处方',
                        value: '处方'
                    }
                ],
                baseData: [],
                showData: [],
                empiValue: '',
                showCheckbox: false,
                showIndex: false,
                columnTitle: [],
                tabValue: '门急诊',
                total: 0,
                pageSize: 5,
                page: 1,
                xmlData: '',
                curRowId: ''
            }
        },
        computed: {
            hlColumns() {
                let columns = [];
                if (this.showCheckbox) {
                    columns.push({
                        type: 'selection',
                        width: 60,
                        align: 'center'
                    });
                }
                if (this.showIndex) {
                    columns.push({
                        type: 'index',
                        width: 55,
                        align: 'center'
                    });
                }
                this.columnTitle.forEach(item => {
                    if (item.title === 'EMPI' || item.title === '姓名' || item.title === '性别' || item.title === '年龄') {
                        columns.push({
                            title: item.title,
                            key: item.key,
                            width: 75,
                            align: 'center',
                            fixed: 'left',
                        });
                    } else if (item.title !== '唯一标识' && item.title === '检查报告结果-客观所见') {
                        columns.push({
                            title: item.title,
                            key: item.key,
                            width: 100,
                            align: 'center',
                            ellipsis: true,
                            render: (h, params) => {
                                return h('div', [
                                    h('Poptip', {
                                            props: {
                                                trigger: 'hover',
                                                placement: 'left-start',
                                                transfer: true,
                                                whiteSpace: 'normal'
                                            },
                                        },
                                        [
                                            h('span', {
                                                props: {
                                                    type: 'text',
                                                    size: 'small',
                                                    icon: 'information-circled'
                                                },
                                                style: {
                                                    padding: '0 2px',
                                                    marginTop: '-2px'
                                                }
                                            }, params.row.image_descr),
                                            h('div', {
                                                slot: 'content',
                                                style: {
                                                    width: '160px',
                                                    whiteSpace: 'normal'
                                                }
                                            }, params.row.image_descr)
                                        ])

                                ])
                            }
                        });
                    } else if (item.title !== '唯一标识' && item.title === '检查报告结果-主观提示') {
                        columns.push({
                            title: item.title,
                            key: item.key,
                            width: 100,
                            align: 'center',
                            ellipsis: true,
                            render: (h, params) => {
                                return h('div', [
                                    h('Poptip', {
                                            props: {
                                                trigger: 'hover',
                                                placement: 'left-start',
                                                transfer: true,
                                                whiteSpace: 'normal'
                                            },
                                        },
                                        [
                                            h('span', {
                                                props: {
                                                    type: 'text',
                                                    size: 'small',
                                                    icon: 'information-circled'
                                                },
                                                style: {
                                                    padding: '0 2px',
                                                    marginTop: '-2px'
                                                }
                                            }, params.row.conclusion),
                                            h('div', {
                                                slot: 'content',
                                                style: {
                                                    width: '160px',
                                                    whiteSpace: 'normal'
                                                }
                                            }, params.row.conclusion)
                                        ])

                                ])
                            }
                        });
                    } else {
                        columns.push({
                            title: item.title,
                            key: item.key,
                            width: 100,
                            align: 'center'
                        });
                    }
                });

                return columns;
            }
        },
        mounted() {
            this.initData();
        },
        methods: {
            search() {
                this.xmlData = '';
                if (this.empiValue !== '') {
                    this.$store.dispatch('searchHl7', {
                        pageSize: this.pageSize,
                        current: this.page,
                        tabValue: this.tabValue,
                        empi: this.empiValue
                    }).then(res => {
                        if(res.success) {
                            this.columnTitle = res.columnData;
                            this.baseData = res.initData;
                            this.total = parseInt(res.total);
                            this.loading = false;
                        }
                    })
                } else {
                    this.initData();
                }
            },

            initData() {
                this.$store.dispatch('initHl7', {
                    pageSize: this.pageSize,
                    current: this.page,
                    tabValue: this.tabValue
                }).then(res => {
                    if(res.success) {
                        this.columnTitle = res.columnData;
                        this.baseData = res.initData;
                        this.total = parseInt(res.total);
                        this.loading = false;
                    }
                })
            },
            changePage(page) {
                this.page = page;
                this.initData()
            },

            revertXml(currentRow, oldRow) {
                this.curRowId = currentRow.view_id;
            },
            beginRevert() {
                this.$store.dispatch('revertXml', {
                    tabValue: this.tabValue,
                    viewId: this.curRowId
                }).then(res => {
                    if (res.success) {
                        this.xmlData = res.xmlData;
                    }
                })
            }
        }
    }
</script>