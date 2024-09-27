import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lab_todo/screen/signin_screen.dart';
import 'firebase_options.dart';
import 'package:lab_todo/models/expense_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SigninScreen(),
    );
  }
}

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;
  String _selectedType = 'Income';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _dateController = TextEditingController();
  }

  void addTransactionHandle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new transaction"),
          content: SizedBox(
            width: 300,
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Amount",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                  items: <String>['Income', 'Expense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Note",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Date",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text = pickedDate.toString();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                CollectionReference transactions =
                    FirebaseFirestore.instance.collection("transactions");
                transactions.add({
                  'userId': FirebaseAuth.instance.currentUser?.uid,
                  'amount': double.parse(_amountController.text),
                  'type': _selectedType,
                  'note': _noteController.text,
                  'date': _dateController.text,
                }).then((res) {
                  print('Transaction added: $res');
                }).catchError((onError) {
                  print("Failed to add transaction: $onError");
                });
                setState(() {
                  _amountController.clear();
                  _noteController.clear();
                  _dateController.clear();
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void editTransactionHandle(BuildContext context, DocumentSnapshot transaction) {
    _amountController.text = transaction['amount'].toString();
    _noteController.text = transaction['note'];
    _dateController.text = transaction['date'];
    _selectedType = transaction['type'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit transaction"),
          content: SizedBox(
            width: 300,
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Amount",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                  items: <String>['Income', 'Expense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Note",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Date",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                transaction.reference.update({
                  'amount': double.parse(_amountController.text),
                  'type': _selectedType,
                  'note': _noteController.text,
                  'date': _dateController.text,
                });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void deleteTransactionHandle(BuildContext context, DocumentSnapshot transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete transaction"),
          content: const Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
              onPressed: () {
                transaction.reference.delete();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SigninScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("transactions")
            .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return const Center(child: Text("No transactions available"));
          }

          // Prepare data for the chart
          List<DocumentSnapshot> transactions = snapshot.data!.docs;

          double totalIncome = 0;
          double totalExpense = 0;

          for (var doc in transactions) {
            if (doc['type'] == 'Income') {
              totalIncome += doc['amount'];
            } else {
              totalExpense += doc['amount'];
            }
          }

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Total Income: $totalIncome",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Total Expense: $totalExpense",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Add the IncomeExpenseChart here
                  SizedBox(
                    height: 300, // Set a height for the chart
                    child: IncomeExpenseChart(transactions: transactions),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        var transaction = transactions[index];
                        var transactionData = transaction.data() as Map<String, dynamic>;
                        var transactionAmount = transactionData['amount'] ?? "No amount";
                        var transactionNote = transactionData['note'] ?? "No note";
                        var transactionType = transactionData['type'] ?? "No type";
                        var transactionDate = transactionData['date'] ?? "No date";

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          elevation: 5,
                          child: ListTile(
                            title: Text("$transactionAmount - $transactionType"),
                            subtitle: Text("$transactionNote\nDate: $transactionDate"),
                            trailing: PopupMenuButton<String>(
                              onSelected: (String value) {
                                if (value == "edit") {
                                  editTransactionHandle(context, transaction);
                                } else if (value == "delete") {
                                  deleteTransactionHandle(context, transaction);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: "edit",
                                  child: Text("Edit"),
                                ),
                                const PopupMenuItem(
                                  value: "delete",
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    addTransactionHandle(context);
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
