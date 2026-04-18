import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_state.dart';
import '../../data/repos/profile_repo.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/repos/auth_repo.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final AuthRepo authRepo;

  ProfileCubit(this.profileRepo, this.authRepo) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final userId = await authRepo.getSessionId();
      if (userId == null) {
        emit(ProfileError('No session found'));
        return;
      }
      final profile = await profileRepo.getProfile(userId);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> saveProfile(UserModel user) async {
    try {
      await profileRepo.updateProfile(user);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> pickAndSavePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        final userId = await authRepo.getSessionId();
        if (userId != null) {
          await profileRepo.updatePhoto(userId, pickedFile.path);
          await loadProfile();
        }
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
