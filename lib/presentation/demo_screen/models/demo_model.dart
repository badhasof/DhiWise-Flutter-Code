import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class defines the variables used in the [demo_screen],
/// and is typically used to hold data that is passed between different parts of the application.
class DemoModel extends Equatable {
  DemoModel();

  DemoModel copyWith() {
    return DemoModel();
  }

  @override
  List<Object?> get props => [];
}
