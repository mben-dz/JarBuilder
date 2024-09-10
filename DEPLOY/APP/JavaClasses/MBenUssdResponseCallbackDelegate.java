package com.MBenDelphi.UssdDemo;

import android.telephony.TelephonyManager;

public interface MBenUssdResponseCallbackDelegate {

  public void onReceiveUssdResponse(TelephonyManager telephonyManager, String request, CharSequence response);

  public void onReceiveUssdResponseFailed(TelephonyManager telephonyManager, String request, int failureCode);

}