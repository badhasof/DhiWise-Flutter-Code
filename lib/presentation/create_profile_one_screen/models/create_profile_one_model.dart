import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class defines the variables used in the [create_profile_one_screen],
/// and is typically used to hold data that is passed between different parts of the application.
class CreateProfileOneModel extends Equatable {
  final String? userName;

  CreateProfileOneModel({this.userName});

  CreateProfileOneModel copyWith({String? userName}) {
    return CreateProfileOneModel(
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [userName];
}
