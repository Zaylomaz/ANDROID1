package com.rempc.app.api;

import android.util.Log;

import com.rempc.app.BuildConfig;

import java.io.IOException;

import okhttp3.HttpUrl;
import okhttp3.Request;
import okhttp3.Interceptor;

public class ProxyInterceptor implements Interceptor {
    private static final String TAG = ProxyInterceptor.class.getName();
    private volatile String host = HttpUrl.parse(BuildConfig.API_URL).host();

    public void setHost(String host) {
        Log.d(TAG, "Set host -> " + host);
        this.host = HttpUrl.parse(host).host();
    }

    @Override
    public okhttp3.Response intercept(Chain chain) throws IOException {
        Request request = chain.request();
        setHost(BuildConfig.PROXY_URL);
        HttpUrl newUrl = request.url().newBuilder()
                .host(host)
                .build();
        request = request.newBuilder()
                .url(newUrl)
                .build();
        return chain.proceed(request);
    }
}