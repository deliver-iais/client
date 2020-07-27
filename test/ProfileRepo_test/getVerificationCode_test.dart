import 'package:deliver_flutter/generated-protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/profileRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

void main(){
  GetIt getIt = GetIt.instance;


  getIt.registerSingleton<AccountRepo>(AccountRepo());

  getIt.registerSingleton<ProfileRepo>(ProfileRepo());
  var profileRepo = GetIt.I.get<ProfileRepo>();
  test("get Verification Code", (){
    Future req = profileRepo.getVerificationCode(98, "9114583949");




  });
}