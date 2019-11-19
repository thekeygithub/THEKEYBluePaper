package com.yibao.mobileapp.util;

/**
 * Created by Administrator on 2018/5/11/011.
 */

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Parcelable;
import android.util.Log;
import android.widget.Toast;

/**
 * 网络改变监控广播
 * <p>
 * 监听网络的改变状态,只有在用户操作网络连接开关(wifi,mobile)的时候接受广播,
 * 然后对相应的界面进行相应的操作，并将 状态 保存在我们的APP里面
 * <p>
 * <p>
 * Created by xujun
 */
public class NetworkConnectChangedReceiver extends BroadcastReceiver {
    /**
     * 获取连接类型
     *
     * @param type
     * @return
     */
    String TAG="tag";
    @Override
    public void onReceive(Context context, Intent intent) {
        // 这个监听wifi的打开与关闭，与wifi的连接无关
       if (WifiManager.NETWORK_STATE_CHANGED_ACTION.equals(intent.getAction())) {
            ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            //移动数据
            NetworkInfo mobNetInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
            //wifi网络
            NetworkInfo wifiNetInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);

            if (!mobNetInfo.isConnected() && !wifiNetInfo.isConnected()) {
//            网络状态全部不可用
                Toast.makeText(context, "无网络", Toast.LENGTH_SHORT).show();
                return;
            }
            if (mobNetInfo.isConnected() || wifiNetInfo.isConnected()) {
                Toast.makeText(context, "已连接网络", Toast.LENGTH_SHORT).show();
                return;
            }


            if (mobNetInfo.isConnected() && !wifiNetInfo.isConnected()) {
//            手机没有处于wifi网络而是处于移动网络
                Toast.makeText(context, "当前处于移动网络", Toast.LENGTH_SHORT).show();
                return;
            }
        }

    }


}