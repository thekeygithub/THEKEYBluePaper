package com.bianque.sys.service.hl7;

import com.bianque.sys.mapper.hl7.Hl7Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class Hl7Service {
    @Autowired
    private Hl7Mapper hl7Mapper;

    public List<Map<String, Object>> initData(Map<String, Object> params) {
        return hl7Mapper.initData(params);
    }

    public List<Map<String, Object>> initEdsData() {
        return hl7Mapper.initEdsData();
    }

    public List<Map<String, Object>> initOutpatData() {
        return hl7Mapper.initOutpatData();
    }

    public List<Map<String, Object>> initLabData() {
        return hl7Mapper.initLabData();
    }

    public List<Map<String, Object>> initExamData() {
        return hl7Mapper.initExamData();
    }

    public List<Map<String, Object>> getOutpatDataXml(String viewId) {
        return hl7Mapper.getOutpatDataXml(viewId);
    }

    public List<Map<String, Object>> getExamDataXml(String viewId) {
        return hl7Mapper.getExamDataXml(viewId);
    }

    public List<Map<String, Object>> getLabDataXml(String viewId) {
        return hl7Mapper.getLabDataXml(viewId);
    }

    public List<Map<String, Object>> getEdsDataXml(String viewId) {
        return hl7Mapper.getEdsDataXml(viewId);
    }

    public List<Map<String, Object>> searchOutpatHl7(String empi) {
            return hl7Mapper.searchOutpatHl7(empi);
    }

    public List<Map<String, Object>> searchExamHl7(String empi) {
        return hl7Mapper.searchExamHl7(empi);
    }

    public List<Map<String, Object>> searchLabHl7(String empi) {
        return hl7Mapper.searchLabHl7(empi);
    }

    public List<Map<String, Object>> searchEdsHl7(String empi) {
        return hl7Mapper.searchEdsHl7(empi);
    }

}
