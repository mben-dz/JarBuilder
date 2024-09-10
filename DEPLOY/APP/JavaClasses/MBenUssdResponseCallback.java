package com.MBenDelphi.UssdDemo;

import android.telephony.TelephonyManager;

public class MBenUssdResponseCallback extends TelephonyManager.UssdResponseCallback {

  private MBenUssdResponseCallbackDelegate mDelegate;

  public MBenUssdResponseCallback(MBenUssdResponseCallbackDelegate delegate) {
    mDelegate = delegate;
  }

  @Override
  public void onReceiveUssdResponse(TelephonyManager telephonyManager, String request, CharSequence response) {
    mDelegate.onReceiveUssdResponse(telephonyManager, request, response);
  }

  @Override
  public void onReceiveUssdResponseFailed(TelephonyManager telephonyManager, String request, int failureCode) {
    mDelegate.onReceiveUssdResponseFailed(telephonyManager, request, failureCode);
  }

}