import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

Future getCategoryCreation(BuildContext context) {
  List<String> myCategoriesIcons = [
    'entertainment',
    'food',
    'home',
    'pet',
    'shopping',
    'tech',
    'travel'
        'other',
  ];

  return showDialog(
      context: context,
      builder: (ctx) {
        bool isExpended = false;
        String iconSelected = '';
        Color categoryColor = Colors.white;
        TextEditingController categoryNameController = TextEditingController();
        TextEditingController categoryIconController = TextEditingController();
        TextEditingController categoryColorController = TextEditingController();
        bool isLoading = false;
        Category category = Category.empty;

        return BlocProvider.value(
          value: context.read<CreateCategoryBloc>(),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return BlocListener<CreateCategoryBloc, CreateCategoryState>(
                listener: (context, state) {
                  if (state is CreateCategorySuccess) {
                    Navigator.pop(ctx, category);
                  } else if (state is CreateCategoryLoading) {
                    setState(() {
                      isLoading = true;
                    });
                  } else if (state is CreateCategoryFailure) {
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: AlertDialog(
                  title: const Text('Create a Category'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: categoryNameController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: categoryIconController,
                          onTap: () {
                            setState(() {
                              isExpended = !isExpended;
                            });
                          },
                          textAlignVertical: TextAlignVertical.center,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Icon',
                            suffixIcon: Icon(
                              isExpended
                                  ? CupertinoIcons.chevron_up
                                  : CupertinoIcons.chevron_down,
                              size: 14,
                            ),
                          ),
                        ),
                        if (isExpended) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 220,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFD),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFE6EBF2)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                                itemCount: myCategoriesIcons.length,
                                itemBuilder: (context, int i) {
                                  final iconName = myCategoriesIcons[i];
                                  final selected = iconSelected == iconName;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        iconSelected = iconName;
                                        categoryIconController.text = iconName;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.12)
                                            : Colors.white,
                                        border: Border.all(
                                          width: selected ? 2 : 1,
                                          color: selected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : const Color(0xFFE6EBF2),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/$iconName.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: categoryColorController,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx2) {
                                return AlertDialog(
                                  title: const Text('Choose color'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ColorPicker(
                                        pickerColor: categoryColor,
                                        onColorChanged: (value) {
                                          setState(() {
                                            categoryColor = value;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          onPressed: () {
                                            Navigator.pop(ctx2);
                                          },
                                          child: const Text('Save Color'),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          textAlignVertical: TextAlignVertical.center,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Color',
                            filled: true,
                            fillColor: categoryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: isLoading == true
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : FilledButton(
                                  onPressed: () {
                                    final name =
                                        categoryNameController.text.trim();
                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please enter a category name.'),
                                        ),
                                      );
                                      return;
                                    }

                                    if (iconSelected.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select a category icon.'),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      category = category.copyWith(
                                        categoryId: const Uuid().v1(),
                                        name: name,
                                        icon: iconSelected,
                                        color: categoryColor.toARGB32(),
                                      );
                                    });

                                    context
                                        .read<CreateCategoryBloc>()
                                        .add(CreateCategory(category));
                                  },
                                  child: const Text('Save Category'),
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      });
}
