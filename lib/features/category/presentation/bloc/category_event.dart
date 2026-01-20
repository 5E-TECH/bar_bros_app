part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class GetAllCategoriesEvent extends CategoryEvent {
  const GetAllCategoriesEvent();
}

class GetAllManCategoriesEvent extends CategoryEvent {
  const GetAllManCategoriesEvent();
}

class GetAllWomanCategoriesEvent extends CategoryEvent {
  const GetAllWomanCategoriesEvent();
}
