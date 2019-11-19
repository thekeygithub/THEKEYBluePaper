package com.bianque.sys.mapper.hl7;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface Hl7Mapper {
    List<Map<String, Object>> initData(Map<String, Object> tableName);

    List<Map<String, Object>> initOutpatData();

    List<Map<String, Object>> initLabData();

    List<Map<String, Object>> initEdsData();

    List<Map<String, Object>> initExamData();

    List<Map<String, Object>> getOutpatDataXml(String viewId);

    List<Map<String, Object>> getExamDataXml(String viewId);

    List<Map<String, Object>> getLabDataXml(String viewId);

    List<Map<String, Object>> getEdsDataXml(String viewId);

    List<Map<String, Object>> searchOutpatHl7(String empi);

    List<Map<String, Object>> searchExamHl7(String empi);

    List<Map<String, Object>> searchLabHl7(String empi);

    List<Map<String, Object>> searchEdsHl7(String empi);
}
