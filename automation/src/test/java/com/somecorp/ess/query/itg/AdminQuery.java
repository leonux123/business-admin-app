package com.somecorp.ess.query.itg;


import org.testng.annotations.Test;
import java.util.Map;

import com.hpe.ess.query.BaseQuery;
import com.qmetry.qaf.automation.testng.dataprovider.QAFDataProvider;

public class AdminQuery extends BaseQuery {

	@QAFDataProvider(dataFile = "data/admin/itg-admin-server.json")
    @Test(description = "Test Script - Validate that all admin servers are active.")
	public void essAdminQuery(Map<String, String> data) {
        super.essAdminQuery(data);
    }

}
