package com.example.flutter_hesabe_payment.api;

import okhttp3.OkHttpClient;
import retrofit2.Retrofit;
import retrofit2.converter.scalars.ScalarsConverterFactory;

public class RetrofitClientInstance {
    private static Retrofit retrofit;

    public static Retrofit getRetrofitInstance(String baseURL) {
        if (retrofit == null) {
            OkHttpClient oktHttpClient = new OkHttpClient();
            retrofit = new Retrofit.Builder()
                    .baseUrl(baseURL)
                    .client(oktHttpClient)
                    .addConverterFactory(ScalarsConverterFactory.create())
                    .build();
        }
        return retrofit;
    }
}
