import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:bar_bros_user/features/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:bar_bros_user/features/category/domain/usecases/get_all_man_categories_usecase.dart';
import 'package:bar_bros_user/features/category/domain/usecases/get_all_woman_categories_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

part 'category_event.dart';
part 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final GetAllManCategoriesUseCase _getAllManCategoriesUseCase;
  final GetAllWomanCategoriesUseCase _getAllWomanCategoriesUseCase;

  CategoryBloc(
    this._getAllCategoriesUseCase,
    this._getAllManCategoriesUseCase,
    this._getAllWomanCategoriesUseCase,
  ) : super(CategoryInitial()) {
    on<GetAllCategoriesEvent>(_onGetAllCategories);
    on<GetAllManCategoriesEvent>(_onGetAllManCategories);
    on<GetAllWomanCategoriesEvent>(_onGetAllWomanCategories);
  }

  Future<void> _onGetAllCategories(
    GetAllCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await _getAllCategoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onGetAllManCategories(
    GetAllManCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await _getAllManCategoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onGetAllWomanCategories(
    GetAllWomanCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await _getAllWomanCategoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }
}
