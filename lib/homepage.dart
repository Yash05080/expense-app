import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keep_the_count/Database/expense_database.dart';
import 'package:keep_the_count/componants/my_list_tile.dart';
import 'package:keep_the_count/helper/helper_functions.dart';
import 'package:keep_the_count/model/expense.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //controller
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    super.initState();
  }

  //open new expense box
  void openNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // user input -> expense name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: "name"),
                  ),
                  // user input -> expense amount
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: "amount"),
                  ),
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),

                //save button
                _saveButton()
              ],
            ));
  }

  //open edit box
  void openEditBox(Expense expense) {
// load previous values into the textfeild
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Edit expense?"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // user input -> expense name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingName),
                  ),
                  // user input -> expense amount
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),
                  ),
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),

                //save button
                _editExpenseButton(expense)
              ],
            ));
  }

  //open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("delete expense?"),
              actions: [
                //cancel button
                _cancelButton(),

                //save button
                _deleteExpenseButton(expense.id)
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
        builder: (context, value, child) => Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: openNewExpenseBox,
              child: Icon(Icons.add),
            ),
            body: ListView.builder(
                itemCount: value.allExpense.length,
                itemBuilder: (context, index) {
                  //get individual expense
                  Expense individualExpense = value.allExpense[index];
                  //return Listtile UI
                  return MyListTile(
                    name: individualExpense.name,
                    amount: formatAmount(individualExpense.amount),
                    Day: individualExpense.date.day.toString(),
                    month: individualExpense.date.month.toString(),
                    year: individualExpense.date.year.toString(),
                    onEditPressed: (context) => openEditBox(individualExpense),
                    onDeletePressed: (context) =>
                        openDeleteBox(individualExpense),
                  );
                })));
  }

  //CANCEL button

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear controller
        nameController.clear();
        amountController.clear();
      },
      child: Text("Cancel"),
    );
  }

  // SAVE button
  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        //only save if bopth name and amount is filled
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());

          //save in db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          //clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: Text("Save"),
    );
  }

  // EDIT button
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //save as long as atleast one textfeild has been changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);
          //create a new updated expenase
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());

          //old expense id
          int existingid = expense.id;

          //save to db
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingid, updatedExpense);
        }
      },
      child: Text("save"),
    );
  }

  //DELETE button
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        //pop box
        Navigator.pop(context);

        //delete the expense
        await context.read<ExpenseDatabase>().deleteExpense(id);
      },
      child: Text("Delete"),
    );
  }
}
