package com.example.websdk_android_demo.net;

public class LoginUrlBean {

    private int code;
    private String msg;
    private Data data;

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    public static class Data{
        private String permission_denied_url;
        private String login_url;

        public String getPermission_denied_url() {
            return permission_denied_url;
        }

        public void setPermission_denied_url(String permission_denied_url) {
            this.permission_denied_url = permission_denied_url;
        }

        public String getLogin_url() {
            return login_url;
        }

        public void setLogin_url(String login_url) {
            this.login_url = login_url;
        }
    }
}
