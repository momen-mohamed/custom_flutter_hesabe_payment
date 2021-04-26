package com.example.flutter_hesabe_payment;

import android.app.Activity;
import android.content.Intent;
import android.view.View;
import android.widget.Button;

import android.annotation.TargetApi;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import android.content.Context;
import android.widget.Toast;


import org.json.JSONObject;



import com.example.flutter_hesabe_payment.api.ApiInterface;
import com.example.flutter_hesabe_payment.api.RetrofitClientInstance;
import com.example.flutter_hesabe_payment.crypto.HesabeCrypt;

import org.json.JSONException;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class HesabepaymentActivity extends Activity {
    // Get all three values from Merchant Panel, Profile section

    public static String EX_SECRET_KEY = "SECRET_KEY";      // Use Secret key
    public static String EX_IV_KEY = "IV_KEY";              // Use Iv Key
    public static String EX_MERCHANT_CODE = "MERCHANT_CODE"; // Use Merchant Code
    public static String EX_ACCESS_CODE = "ACCESS_CODE";
    public static String EX_RETURN_URL = "RETURN_URL";
    public static String Ex_BASE_URL = "BASE_URL";
    public static String Ex_Name = "Name";
    public static String Ex_Price = "Price";


    HesabeCrypt hesabeCrypt;

    private String Name;
    private double Price;
    private String BASE_URL ;

    public String SECRET_KEY ;    // Use Secret key
    public String IV_KEY ;        // Use Iv Key
    public String MERCHANT_CODE; // Use Merchant Code
    public String ACCESS_CODE;
    public String RETURN_URL;


    private boolean flag = false;
    String amount, paymentToken, paymentId, administrativeCharge, variable1;


    WebView webView;
    Context context ;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_view);
context = this;

        webView = findViewById(R.id.web_view);
       /* Initialise HesabeCrypt class with the given credentials */

        Intent intent = getIntent();
        BASE_URL = intent.getStringExtra(Ex_BASE_URL);
        Name = intent.getStringExtra(Ex_Name);
        Price = intent.getDoubleExtra(Ex_Price,0.0);

        SECRET_KEY = intent.getStringExtra(EX_SECRET_KEY);
        IV_KEY = intent.getStringExtra(EX_IV_KEY);
        MERCHANT_CODE = intent.getStringExtra(EX_MERCHANT_CODE);
        ACCESS_CODE = intent.getStringExtra(EX_ACCESS_CODE);
        RETURN_URL = intent.getStringExtra(EX_RETURN_URL);


        hesabeCrypt = new HesabeCrypt(SECRET_KEY, IV_KEY);
        checkout();
    }

    private void checkout(){
        /* Get payment request object*/
        JSONObject obj = getPaymentRequestObject();

        /* Encrypt the Data */
        String encryptedData = hesabeCrypt.encrypt(obj.toString());

        /* Check out the request using any REST Client (in our case we are using Retrofit) */
        checkoutRequest(encryptedData);
    }

    private JSONObject getPaymentRequestObject(){
        JSONObject obj = new JSONObject();
        try {
            obj.put("merchantCode", MERCHANT_CODE); //Use merchant code
            obj.put("amount",Price); //Total amount
            obj.put("paymentType", "0"); //Type of the payment
            obj.put("responseUrl", RETURN_URL);
            //Given URL end point will be used to check the result
            obj.put("failureUrl",RETURN_URL);
            obj.put("version", "2.0"); //Hesabe Payment Gateway version
            obj.put("variable1", "#OR12345"); //Order ID or any other variable which will get back after payment completes.
            obj.put("variable2", "");
            obj.put("variable3", "");
            obj.put("variable4", "");
            obj.put("variable5", "");
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return obj;
    }

    private void checkoutRequest(String encryptedData){
        ApiInterface service = RetrofitClientInstance.getRetrofitInstance(BASE_URL).create(ApiInterface.class);
        Call<String> call = service.hesabePay(ACCESS_CODE,encryptedData);
        call.enqueue(new Callback<String>() {
            @Override
            public void onResponse(Call<String> call, Response<String> response) {
                if (response.body() != null) {
                    try {
                        processResponse(response.body());
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            @Override
            public void onFailure(Call<String> call, Throwable t) {
                t.getMessage();
            }
        });
    }

    private void processResponse(String response) {
        try {
            /* Decrypt Response */
            byte[] decryptedResponse = hesabeCrypt.decrypt(response);
            String trimmedData = new String(decryptedResponse).replaceAll("\\s+", " ").trim();

            /* Get token from decrypted response */
            String responseToken = new JSONObject(trimmedData).getJSONObject("response").getString("data");

            /* Create payment URL with response token */
            String paymentURL = BASE_URL.concat("/payment?data=").concat(responseToken);

            /* Open WebView Activity to load the URL */
            redirectToPayment(paymentURL);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void redirectToPayment(String paymentURL) {
        /* Initialise HesabeCrypt class with the given credentials */
        hesabeCrypt = new HesabeCrypt(SECRET_KEY, IV_KEY);
        /* Get the Payment URL passed from MainActivity */
        String url = paymentURL;
        /* Load the URL in WebView */
        redirectToPaymentFinal(url);
    }

    @TargetApi(Build.VERSION_CODES.GINGERBREAD)
    private void redirectToPaymentFinal(String url) {
        if (url != null && !url.isEmpty()) {
            webView.loadUrl(url);
            WebSettings webSettings = webView.getSettings();
            webSettings.setJavaScriptEnabled(true);
            webView.setWebViewClient(new WebViewClient(){
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, final String url) {
                    if(!flag) {
                        view.loadUrl(url);
                        return true;
                    }
                    return false;
                }

                @Override
                public void onPageFinished(WebView view, String url) {
                    super.onPageFinished(view, url);

                    /* Check if URL contains the value given at 'responseUrl' field */
                    if(url.contains(RETURN_URL)){
                        flag = true;
                        /* If yes, parse the result */
                        parseResultFinal(url);
                    }
                }
            });
        }
    }

    private void parseResultFinal(String url) {
        Uri parse = Uri.parse(url);
        String data = parse.getQueryParameter("data");
        try {
            /* Decrypt the result */
            byte[] decrypt = hesabeCrypt.decrypt(data);
            String decryptedData =  new String(decrypt).replaceAll("\\s+"," ").trim();

            /* Get the decrypted data as a JSONObject */
            JSONObject decryptedObject = new JSONObject(decryptedData).getJSONObject("response");

           // Toast.makeText(context,"Dec" + decryptedObject.toString(),Toast.LENGTH_SHORT).show();

            /* Get the Result code */
            String resultCode = decryptedObject.getString("resultCode");

           // Toast.makeText(context,"resultCode" + resultCode.toString(),Toast.LENGTH_SHORT).show();

            /* Get other details */
            amount = decryptedObject.getString("amount");
            paymentToken = decryptedObject.getString("paymentToken");
            paymentId = decryptedObject.getString("paymentId");
            administrativeCharge = decryptedObject.getString("administrativeCharge");
            variable1 = decryptedObject.getString("variable1");


            String parseData = decryptedObject.toString();
            String text = "Success\n\nResponse:\n\n" + parseData;
            try {
                Intent back = new Intent();
                back.putExtra("data", parseData);
                setResult(Activity.RESULT_OK, back);
                finish();
            } catch (Exception ignored) {
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
