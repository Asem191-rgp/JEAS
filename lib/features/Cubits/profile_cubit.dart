import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProfileCubitState {
  String? userName;
  String? description;
  String? birthday;

  ProfileCubitState({String? name, String? desc})
      : userName = name,
        description = desc;
}

class ProfileInitValue extends ProfileCubitState {
  ProfileInitValue() : super(name: "", desc: "Tap to add text");
}

class AddUserNameState extends ProfileCubitState {
  AddUserNameState(String value) : super(name: value);
}

class AddDescState extends ProfileCubitState {
  AddDescState(String value) : super(desc: value);
}

class AddBirthdayState extends ProfileCubitState {
  AddBirthdayState(String value) : super(desc: value);
}

class ProfileCubit extends Cubit<ProfileCubitState> {
  ProfileCubit() : super(ProfileInitValue());

  static ProfileCubit get(BuildContext context) {
    return BlocProvider.of(context);
  }

  String description = "Tap to add text";
  String name = "";
  String birthday = "";

  void addDesc(String value) {
    description = value;
    emit(AddDescState(description));
  }

  void addBirthday(String value) {
    birthday = value;
    emit(AddBirthdayState(birthday));
  }

  void addName(String value) {
    name = value;
    emit(AddUserNameState(name));
  }
}
