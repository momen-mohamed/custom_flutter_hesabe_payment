package com.example.flutter_hesabe_payment.api;


import retrofit2.Call;
import retrofit2.http.Headers;
import retrofit2.http.POST;
import retrofit2.http.Query;
import retrofit2.http.Header;

public interface ApiInterface {
    @POST("/checkout")
   /* @Headers({"accessCode: " + Constants.ACCESS_CODE})*/
    Call<String> hesabePay(@Header("accessCode") String accessCode,@Query("data") String data);
}
