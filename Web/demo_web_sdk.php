<?php


namespace App\Http\Controllers\Platform;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Tools\Utils;
use App\Http\Controllers\Tools\XiaoeLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\Redis;

/**
 * webSDK Demo
 *
 * Class DemoWebSdkController
 * @package App\Http\Controllers\Platform
 */
class DemoWebSdkController extends Controller
{
    /**
     * 店铺id
     */
    CONST APP_ID = 'xxxxxxxxx';

    /**
     * 应用的唯一标识，通过 client_id 来鉴别应用的身份
     */
    CONST CLIENT_ID = 'xxxxxxxxx';

    /**
     * 应用的凭证秘钥，即client_secret，用来保证应用来源的可靠性，防止被伪造
     */
    CONST SECRET_KEY = 'xxxxxxxxx';

    /**
     * 固定填写client_credential
     */
    CONST GRANT_TYPE = 'xxxxxxxxx';

    /**
     * 获取acess_token url
     */
    CONST ACCESS_TOKEN_URL = 'http://api.xiaoe-tech.com/token';

    /**
     * 获取登录链接 url
     */
    CONST GET_LOGIN_URL = 'http://api.xiaoe-tech.com/xe.login.url/1.0.0';


    /**
     * 模拟登录
     *
     * @author: l
     * @Time: 2020-11-05 15:22
     */
    public function demoSdk(Request $request)
    {
        $user_id = $request->input('user_id');
        $app_id = $request->input('app_id',self::APP_ID);
        $client_id = $request->input('client_id', self::CLIENT_ID);
        $client_secret = $request->input('client_secret', self::SECRET_KEY);
        $grant_type = $request->input('grant_type', self::GRANT_TYPE);
        $banner_url = $request->input('banner_url');
        // 获取 access_token 2小时内有效，每日限频 2000 次
        $access_token = $this->getAccessToken($app_id,$client_id,$client_secret,$grant_type);
        if (is_array($access_token)) {
            return $access_token;
        }
        $login_res = $this->getLoginUrl($app_id,$access_token, $user_id,$banner_url);
        return $login_res;
    }

    /**
     * 获取 access_token
     * 接口文档：https://api-doc.xiaoe-tech.com/index.php?s=/2&page_id=4158
     *
     * @return string
     * @author: l
     * @Time: 2020-11-05 14:50
     */
    public function getAccessToken($app_id,$client_id,$client_secret,$grant_type)
    {
        $redis_handle = Redis::connection("cache_data");
        $cache_key = 'access_token:' . $app_id;
        $access_token = $redis_handle->get($cache_key);
        if ($access_token) {
            return $access_token;
        }

        $get_access_token_url = self::ACCESS_TOKEN_URL;
        $params = [
            'app_id' => $app_id,
            'client_id' => $client_id,
            'secret_key' => $client_secret,
            'grant_type' => $grant_type,
        ];
        $res = $this->curl_get($get_access_token_url, $params);
        /**
         * 返回数据格式
         * {
         * "code": 0,
         * "msg": "success",
         * "data": {
         * "access_token": "xe_xxx",
         * "expires_in": 7200
         * }
         * }
         **/
        $res = @json_decode($res, true);
        if (isset($res['code']) && $res['code'] == 0 && isset($res['data']['access_token'])) {
            $redis_handle->set($cache_key, $res['data']['access_token']);
            $redis_handle->expire($cache_key, 60 * 90);
            return $res['data']['access_token'];
        } else {
            return $res;
        }
    }

    /**
     * 获取登录链接
     * 文档：https://note.youdao.com/ynoteshare1/index.html?id=0fa81d6db74e89aa3f3a56a4426ba488&type=note
     *
     * @param $access_token
     * @param $user_id
     * @return mixed
     * @author: l
     * @Time: 2020-11-05 15:18
     */
    public function getLoginUrl($app_id,$access_token, $user_id,$banner_url)
    {
        /**
         * 请求登录链接参数
         * {
         * "access_token":"xe_xxx",
         * "user_id":"u_5f0d6f3ea11e3_ANep9PK2Um",
         * "data" : {
         * "login_type":2,
         * }
         * }
         **/
        $params = [
            'access_token' => $access_token,
            'user_id' => $user_id,
            'data' => [
                'login_type' => 2,
                'redirect_uri' => $banner_url,
            ]
        ];

        $get_login_url = self::GET_LOGIN_URL;
        $res = $this->curlRequestJson($get_login_url, true, json_encode($params));
        /**
         * 接口返回格式
         * {
         * "code": 0,
         * "data": {
         * "permission_denied_url": "",
         * "login_url": "https://h5.inside.xiaoe-tech.com/platform/login_cooperate/h5_login?token=7f720739a3a15aef2a769da17033c0d5"
         * },
         * "msg": "success"
         * }
         **/
        $res = @json_decode($res, true);
        // 兼容灰度，url带app_id参数
        if($res['code'] == 0 && isset($res['data']) && isset($res['data']['login_url'])) {
            $res['data']['login_url'] = $res['data']['login_url'] . '&app_id='.$app_id;
        }
        if($res['code'] == 10102 && isset($res['data']) && isset($res['data']['permission_denied_url'])) {
            $res['data']['permission_denied_url'] = $res['data']['permission_denied_url'] . '&app_id='.$app_id;
        }
        return $res;
    }

    /**
     * @param $url
     * @param $params
     * @return bool|string
     * 发送get请求
     */
    public function curl_get($url, $params)
    {
        $paramsSeg = [];
        if (count($params) > 0) {
            foreach ($params as $key => $value) {
                $paramsSeg[] = $key . '=' . $value;
            }
        }
        $url = count($paramsSeg) > 0 ? $url . "?" . implode("&", $paramsSeg) : $url;
        return file_get_contents($url, false, stream_context_create([
            'ssl' => [
                'verify_peer' => false,
                'verify_peer_name' => false
            ]
        ]));
    }

    /**
     * @param $targetUrl
     * @param $setPost
     * @param $jsonParam
     * @param null $desc
     * @param int $timeOut
     * @return mixed
     * curl工具
     */
    public function curlRequestJson($targetUrl, $setPost, $jsonParam, $desc = null, $timeOut = 3)
    {
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $targetUrl);
        curl_setopt($curl, CURLOPT_HEADER, false); // 不显示http头部
        $httpHeader[0] = "Accept:application/json";
        $httpHeader[1] = "charset=utf-8";
        $httpHeader[2] = "Content-Type:application/json";
        curl_setopt($curl, CURLOPT_HTTPHEADER, $httpHeader);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false); // 是否验证证书
        curl_setopt($curl, CURLOPT_TIMEOUT, $timeOut);
        if ($setPost) {
            if (Utils::isEmptyString($jsonParam)) {
                curl_setopt($curl, CURLOPT_POSTFIELDS, true); // 设置post
            } else {
                curl_setopt($curl, CURLOPT_POSTFIELDS, $jsonParam); // 设置post参数
            }
        }
        $resultJson = PlatformTools::curlExec($curl, $desc);
        curl_close($curl);

        return $resultJson;
    }

    /**
     * 重定向
     *
     * @param $url
     * @author: l
     * @Time: 2020-11-05 15:24
     */
    public function redirect($url)
    {
        header("Location: $url");
        exit();
    }


}