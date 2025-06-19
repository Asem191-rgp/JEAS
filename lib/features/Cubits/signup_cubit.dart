import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupCubit extends Cubit<SignUpState> {
  SignupCubit() : super(SignupInitState());
  static SignupCubit get(BuildContext context) {
    return BlocProvider.of(context);
  }

  TextEditingController job = TextEditingController();
  TextEditingController birthDay = TextEditingController();
  String personality = "Customer";

  void addJob(String value) {
    job.text = value;
    emit(AddjobState(job.text));
  }

  void addBirthday(String value) {
    birthDay.text = value;
    emit(AddBirthdayState(birthDay.text));
  }

  void addPersonality(String value) {
    personality = value;
    emit(AddPersonalityState(personality));
  }
}

abstract class SignUpState {
  TextEditingController job;
  TextEditingController birthDay;
  String? personality;

  SignUpState({String? j, String? b, String? p})
      : job = TextEditingController(text: j),
        birthDay = TextEditingController(text: b),
        personality = p;
}

class SignupInitState extends SignUpState {
  SignupInitState() : super(j: "", b: "", p: "Customer");
}

class AddjobState extends SignUpState {
  AddjobState(String value) : super(j: value);
}

class AddPersonalityState extends SignUpState {
  AddPersonalityState(String value) : super(p: value);
}

class AddBirthdayState extends SignUpState {
  AddBirthdayState(String value) : super(b: value);
}
