package com.example.websdk_android_demo.net;

import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Headers;
import retrofit2.http.POST;

public interface LoginApi {

    @Headers({"Content-Type: application/json","Accept: application/json"})
    @POST("platform/demo_sdk")
    Call<ResponseBody> getLoginUrl(@Body RequestBody info);
}