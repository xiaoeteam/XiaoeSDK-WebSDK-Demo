package com.example.websdk_android_demo;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.Toast;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import com.example.websdk_android_demo.net.LoginApi;
import com.example.websdk_android_demo.net.LoginUrlBean;
import com.google.gson.Gson;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class WebSDKTestActivity extends AppCompatActivity {

    private WebView mWebView;
    private ProgressBar mProgressBar;
    private Button mConfirmBtn;
    private AlertDialog mLoginDlg;

    private String bannerUrl;
    private String interceptUrl;
    private String appId;
    private String userId;
    private String clientId;
    private String clientSecret;
    private String loginUrl;

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_sdk);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowTitleEnabled(true);
            actionBar.setDisplayShowHomeEnabled(true);
            actionBar.setDisplayShowCustomEnabled(true);
        }

        //小鹅SDK测试页面
        bannerUrl = getIntent().getStringExtra("banner");
        //登录拦截字符串
        interceptUrl = getIntent().getStringExtra("intercept");
        //店铺ID
        appId = getIntent().getStringExtra("appId");
        //用户ID
        userId = getIntent().getStringExtra("userId");
        //小鹅通B端开通SDK服务后取得的clientId
        clientId = getIntent().getStringExtra("clientId");
        //小鹅通B端开通SDK服务后取得的secretKey
        clientSecret = getIntent().getStringExtra("clientSecret");
        //获取登录链接的接口
        loginUrl = getIntent().getStringExtra("loginUrl");

        mWebView = findViewById(R.id.web_sdk_view);
        mProgressBar = findViewById(R.id.web_progress);
        View loginLayout = LayoutInflater.from(WebSDKTestActivity.this).inflate(R.layout.login_dialog_layout, null);
        mConfirmBtn = loginLayout.findViewById(R.id.confirm_login_btn);
        mLoginDlg = new AlertDialog.Builder(WebSDKTestActivity.this).setView(loginLayout).create();

        mConfirmBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mLoginDlg != null && mLoginDlg.isShowing()) {
                    mLoginDlg.dismiss();
                    doLogin();
                }
            }
        });

        loadUrl();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater menuInflater = getMenuInflater();
        menuInflater.inflate(R.menu.tools, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item){
        switch (item.getItemId()){
            case android.R.id.home:
                this.finish();
                return true;
            case R.id.fresh:
                mWebView.reload();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void onBackPressed() {
        //网页回退逻辑，根据自身业务修改
        if (mWebView.canGoBack()){
            mWebView.goBack();
            return;
        }
        super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        //WebView销毁回收
        mWebView.setWebChromeClient(null);
        mWebView.setWebViewClient(null);
        mWebView.setTag(null);
        mWebView.clearHistory();
        mWebView.destroy();
        super.onDestroy();
    }

    @SuppressLint({"NewApi", "SetJavaScriptEnabled"})
    private void loadUrl() {
        //WebSettings的常规设置，根据自身业务增减
        mWebView.setScrollBarStyle(View.SCROLLBARS_OUTSIDE_OVERLAY);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.getSettings().setLoadsImagesAutomatically(true);
        mWebView.getSettings().setDomStorageEnabled(true);
        mWebView.getSettings().setUseWideViewPort(false);
        mWebView.getSettings().setLoadWithOverviewMode(false);
        mWebView.getSettings().setAllowFileAccess(true);
        mWebView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
        mWebView.getSettings().setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);
        mWebView.getSettings().setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        mWebView.getSettings().setMediaPlaybackRequiresUserGesture(false);
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                String url = request.getUrl().toString();
                try {
                    url = URLDecoder.decode(url, "UTF-8");
                } catch (UnsupportedEncodingException ex) {
                    ex.printStackTrace();
                }
                //WebView拦截处理（包括获取登录链接和支付相关）
                return intercept(view, url);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                //WebView拦截处理（包括获取登录链接和支付相关）
                return intercept(view, url);
            }
        });
        mWebView.setWebChromeClient(new WebChromeClient(){
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                mProgressBar.setVisibility(View.VISIBLE);
                mProgressBar.setProgress(newProgress);
                if (newProgress == 100) {
                    //加载完毕隐藏进度条
                    mProgressBar.setVisibility(View.GONE);
                }
                super.onProgressChanged(view, newProgress);
            }
        });
        //加载网页链接同时需要在Cookie中增加"xe_websdk=1"(固定)
        mWebView.loadUrl(bannerUrl);
        CookieSyncManager.createInstance(this);
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        cookieManager.setCookie(bannerUrl, "xe_websdk=1");
        CookieSyncManager.getInstance().sync();
    }

    private boolean intercept(WebView view, String url) {
        //如果拦截到请求登录的url，第三方调用接口获取登录后的链接（这里只是测试，具体接口和逻辑根据自身业务修改）
        if (url.contains(interceptUrl)) {
            if (mLoginDlg != null && !mLoginDlg.isShowing()) {
                mLoginDlg.show();
            }
            return true;
        }
        //如果拦截到H5支付的链接，在WebView请求头加入如下（key：referer；value=https://h5-pay.sdk.xiaoe-tech.com 固定）
        if (url.startsWith("https://wx.tenpay.com")) {
            Map<String, String> extraHeaders = new HashMap<>();
            extraHeaders.put("referer", "https://h5-pay.sdk.xiaoe-tech.com");
            view.loadUrl(url, extraHeaders);
            return true;
        }
        //如果拦截到如下url，跳转到微信进行支付
        if (url.startsWith("weixin://")) {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(url));
            this.startActivity(intent);
            return true;
        }
        return false;
    }

    //调用接口获取登录后链接
    private void doLogin() {
        try {
            JSONObject param = new JSONObject();
            try {
                param.put("app_id", appId);
                param.put("user_id", userId);
                param.put("client_id", clientId);
                param.put("client_secret", clientSecret);
                param.put("grant_type", "client_credential");
                param.put("banner_url", bannerUrl);
            } catch (JSONException e) {
                e.printStackTrace();
            }

            String baseUrl = loginUrl.split("platform/demo_sdk")[0];
            if (baseUrl.isEmpty()) {
                baseUrl = "https://platform.h5.xiaoe-tech.com/";
            }
            Retrofit retrofit = new Retrofit.Builder().baseUrl(baseUrl).build();
            RequestBody body = RequestBody.create(okhttp3.MediaType.parse("application/json; charset=utf-8"), param.toString());
            final LoginApi login = retrofit.create(LoginApi.class);
            retrofit2.Call<ResponseBody> data = login.getLoginUrl(body);
            data.enqueue(new Callback<ResponseBody>() {
                @Override
                public void onResponse(retrofit2.Call<ResponseBody> call, Response<ResponseBody> response) {
                    try {
                        Gson gson = new Gson();
                        LoginUrlBean loginUrlBean = gson.fromJson(response.body().string(), LoginUrlBean.class);
                        //登录成功后（网页已经有登录态，刷新一下网页或者加载返回有登录态的接口）
                        if (loginUrlBean.getCode() == 0 && loginUrlBean.getData() != null) {
                            mWebView.loadUrl(loginUrlBean.getData().getLogin_url());
                        } else if (loginUrlBean.getCode() == 10102 && loginUrlBean.getData() != null) {
                            mWebView.loadUrl(loginUrlBean.getData().getPermission_denied_url());
                        } else {
                            Toast.makeText(WebSDKTestActivity.this, "登录失败, code = " + loginUrlBean.getCode() + " ," +
                                    " msg = " + loginUrlBean.getMsg(), Toast.LENGTH_SHORT).show();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(retrofit2.Call<ResponseBody> call, Throwable t) {
                    Toast.makeText(WebSDKTestActivity.this, "登录失败", Toast.LENGTH_SHORT).show();
                }
            });
        } catch (IllegalArgumentException e) {
            Toast.makeText(WebSDKTestActivity.this, "链接配置错误", Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }
}