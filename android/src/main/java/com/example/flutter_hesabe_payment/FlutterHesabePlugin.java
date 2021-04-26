package com.example.flutter_hesabe_payment;

import android.app.Activity;
import android.content.Intent;
import java.util.HashMap;
import java.util.Map;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterHesabePlugin */
public class FlutterHesabePlugin implements MethodCallHandler , PluginRegistry.ActivityResultListener {
  private  final MethodChannel channel;
  private Activity activity;
  private Result pendingResult;
  private Map<String, Object> arguments;

  public FlutterHesabePlugin(Activity activity, MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;
    this.channel.setMethodCallHandler(this);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_hesabe_payment");
    FlutterHesabePlugin obj = new FlutterHesabePlugin(registrar.activity(),channel);
    channel.setMethodCallHandler(obj);
    registrar.addActivityResultListener(obj);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    pendingResult = result;
    if (call.method.equals("payment")) {
      arguments = (Map<String, Object>) call.arguments;

      Intent intent = new Intent(activity,HesabepaymentActivity.class);
      intent.putExtra(HesabepaymentActivity.Ex_BASE_URL,(String) arguments.get("cred_url"));
      intent.putExtra(HesabepaymentActivity.Ex_Name,(String) arguments.get("name"));
      intent.putExtra(HesabepaymentActivity.Ex_Price,(double) arguments.get("price"));

      intent.putExtra(HesabepaymentActivity.EX_SECRET_KEY,(String) arguments.get("secret_key"));
      intent.putExtra(HesabepaymentActivity.EX_IV_KEY,(String) arguments.get("iv_key"));
      intent.putExtra(HesabepaymentActivity.EX_MERCHANT_CODE,(String)arguments.get("merchant_code"));
      intent.putExtra(HesabepaymentActivity.EX_ACCESS_CODE,(String)arguments.get("access_code"));
      intent.putExtra(HesabepaymentActivity.EX_RETURN_URL,(String)arguments.get("response_URL"));

      activity.startActivityForResult(intent,8888);
    } else {
      result.notImplemented();
    }
  }
  @SuppressWarnings("unused")
  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
    HashMap<String, String> data = new HashMap<>();
    if (requestCode == 8888) {
      if (resultCode == Activity.RESULT_OK) {
        Log.e("Activity.RESULT_OK","Activity.RESULT_OK");
        if(intent.getStringExtra("data")!=null){
          String response = intent.getStringExtra("data");
          data.put("code", "1");
          data.put("message", response);
          pendingResult.success(response);
        }
      }else{
        Log.e("Else Activity.RESULT_OK","Else Activity.RESULT_OK");
        data.put("code", "1");
        data.put("message", "cancel");
        pendingResult.success("cancel");
      }
      pendingResult = null;
      arguments = null;
      return true;
    }
    return false;
  }
}
