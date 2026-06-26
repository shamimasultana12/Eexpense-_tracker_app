import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/views/category_creation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpense({super.key, this.expenseToEdit});

  bool get isEditing => expenseToEdit != null;

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  late Expense expense;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    expense = widget.expenseToEdit ?? Expense.empty;

    if (widget.isEditing) {
      expenseController.text = expense.amount.toStringAsFixed(0);
      categoryController.text = expense.category.name;
      dateController.text = DateFormat('dd/MM/yyyy').format(expense.date);
    } else {
      dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      expense = expense.copyWith(expenseId: const Uuid().v1());
    }
  }

  void _showCategoryBottomSheet(
      BuildContext context, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Select Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, int i) {
                    final category = categories[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tileColor: const Color(0xFFF8FAFD),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(category.color),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/${category.icon}.png',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: expense.category == category
                          ? const Icon(Icons.check_circle_rounded,
                              color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          expense = expense.copyWith(category: category);
                          categoryController.text = category.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (widget.isEditing) {
          return;
        }

        if (state is CreateExpenseSuccess) {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context, expense);
        } else if (state is CreateExpenseLoading) {
          setState(() {
            isLoading = true;
          });
        } else if (state is CreateExpenseFailure) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.isEditing ? 'Edit Expense' : 'Add Expense',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x220B63F6),
                              blurRadius: 24,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New expense',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Capture a transaction with a clean, fast flow.',
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _FieldCard(
                        child: TextFormField(
                          controller: expenseController,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: FaIcon(
                                FontAwesomeIcons.dollarSign,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FieldCard(
                        child: TextFormField(
                          controller: categoryController,
                          textAlignVertical: TextAlignVertical.center,
                          readOnly: true,
                          onTap: () => _showCategoryBottomSheet(
                              context, state.categories),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: expense.category == Category.empty
                                ? const Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.list,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      'assets/${expense.category.icon}.png',
                                      scale: 2,
                                    ),
                                  ),
                            suffixIcon: const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            final newCategory =
                                await getCategoryCreation(context);
                            if (newCategory is Category) {
                              setState(() {
                                state.categories.insert(0, newCategory);
                                expense =
                                    expense.copyWith(category: newCategory);
                                categoryController.text = newCategory.name;
                              });
                            }
                          },
                          icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
                          label: const Text('Add New Category'),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _FieldCard(
                        child: TextFormField(
                          controller: dateController,
                          textAlignVertical: TextAlignVertical.center,
                          readOnly: true,
                          onTap: () async {
                            DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: expense.date,
                              firstDate: DateTime(2000),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );

                            if (newDate != null) {
                              setState(() {
                                dateController.text =
                                    DateFormat('dd/MM/yyyy').format(newDate);
                                expense = expense.copyWith(date: newDate);
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: FaIcon(
                                FontAwesomeIcons.clock,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: () async {
                                  final amountText =
                                      expenseController.text.trim();
                                  final amount = int.tryParse(amountText);

                                  if (amountText.isEmpty || amount == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please enter a valid expense amount.'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (expense.category == Category.empty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Please select a category.'),
                                      ),
                                    );
                                    return;
                                  }

                                  final updatedExpense = expense.copyWith(
                                    amount: amount.toDouble(),
                                  );

                                  setState(() {
                                    expense = updatedExpense;
                                  });

                                  if (widget.isEditing) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    final expenseRepository =
                                        context.read<ExpenseRepository>();
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final navigator = Navigator.of(context);

                                    try {
                                      await expenseRepository
                                          .updateExpense(updatedExpense);
                                      if (!mounted) return;
                                      setState(() {
                                        isLoading = false;
                                      });
                                      navigator.pop(updatedExpense);
                                    } catch (error) {
                                      if (!mounted) return;
                                      setState(() {
                                        isLoading = false;
                                      });
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(error.toString()),
                                        ),
                                      );
                                    }
                                  } else {
                                    context
                                        .read<CreateExpenseBloc>()
                                        .add(CreateExpense(updatedExpense));
                                  }
                                },
                                child: Text(
                                  widget.isEditing
                                      ? 'Update Expense'
                                      : 'Save Expense',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                      )
                    ],
                  ),
                );
              } else if (state is GetCategoriesFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to load categories. Please check your Firebase configuration.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<GetCategoriesBloc>()
                                .add(GetCategories());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;

  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: child,
    );
  }
}
