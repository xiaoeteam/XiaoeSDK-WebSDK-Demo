package com.example.websdk_android_demo;

import androidx.appcompat.app.AppCompatActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

    private String bannerUrl;
    private String interceptUrl;
    private String appId;
    private String userId;
    private String clientId;
    private String clientSecret;
    private String loginUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViewById(R.id.web_sdk_into_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getParam();

                if (bannerUrl.isEmpty()) {
                    Toast.makeText(MainActivity.this, "Banner Url不能为空", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (interceptUrl.isEmpty()) {
                    Toast.makeText(MainActivity.this, "拦截 Url不能为空", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (appId.isEmpty()) {
                    Toast.makeText(MainActivity.this, "appId不能为空", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (userId.isEmpty()) {
                    Toast.makeText(MainActivity.this, "userId不能为空", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (clientId.isEmpty()) {
                    Toast.makeText(MainActivity.this, "clientId不能为空", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (clientSecret.isEmpty()) {
                    Toast.makeText(MainActivity.this, "clientSecret不能为空", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (loginUrl.isEmpty()) {
                    Toast.makeText(MainActivity.this, "loginUrl不能为空", Toast.LENGTH_SHORT).show();
                    return;
                }

                Intent intent = new Intent(MainActivity.this, WebSDKTestActivity.class);
                intent.putExtra("banner", bannerUrl);
                intent.putExtra("intercept", interceptUrl);
                intent.putExtra("appId", appId);
                intent.putExtra("userId", userId);
                intent.putExtra("clientId", clientId);
                intent.putExtra("clientSecret", clientSecret);
                intent.putExtra("loginUrl", loginUrl);
                startActivity(intent);
            }
        });
    }

    private void getParam() {
        EditText bannerEdit = findViewById(R.id.web_sdk_banner_edit);
        bannerUrl = bannerEdit.getText().toString();

        EditText interceptEdit = findViewById(R.id.web_sdk_catch_edit);
        interceptUrl = interceptEdit.getText().toString();

        EditText appIdEdit = findViewById(R.id.web_sdk_appid_edit);
        appId = appIdEdit.getText().toString();

        EditText userIdEdit = findViewById(R.id.web_sdk_userid_edit);
        userId = userIdEdit.getText().toString();

        EditText clientIdEdit = findViewById(R.id.web_sdk_clientid_edit);
        clientId = clientIdEdit.getText().toString();

        EditText clientSecretEdit = findViewById(R.id.web_sdk_secret_edit);
        clientSecret = clientSecretEdit.getText().toString();

        EditText loginUrlEdit = findViewById(R.id.web_sdk_loginurl_edit);
        loginUrl = loginUrlEdit.getText().toString();
    }
}