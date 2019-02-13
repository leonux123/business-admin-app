package com.somecorp.ess.query;

import static io.restassured.RestAssured.given;

import java.util.Map;

import io.restassured.RestAssured;

public class BaseQuery {

    public void essAdminQuery(Map<String, String> data) {

        RestAssured.baseURI = data.get("server");
        RestAssured.port = Integer.parseInt(data.get("port"));
        RestAssured.useRelaxedHTTPSValidation();

        given().when().get("/admin")
                .then().statusCode(Integer.parseInt(data.get("status"))).assertThat();
    }

}
