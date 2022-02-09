import 'dart:async';

import 'package:flutter/services.dart';


enum UserCallState {
  /// User in Group Call then he Can't join any User or Start Own Call
  INGROUPCALL,

  /// User in User Call then he Can't join any Group or Start Own Call
  INUSERCALL,

  /// User Out of Call then he Can join any Group or User Call or Start Own Call
  NOCALL,
}

class CallService {

  UserCallState _callState = UserCallState.NOCALL;

  UserCallState get getUserCallState => _callState;

  set setUserCallState(UserCallState cs) => _callState = cs;

}
