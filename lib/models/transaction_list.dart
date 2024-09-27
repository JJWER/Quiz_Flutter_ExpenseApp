import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Add this line
import 'package:lab_todo/models/transaction.dart';


class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

        return ListView.builder(
          itemCount: snapshot.data?.docs.length,
          itemBuilder: (context, index) {
            var transaction = snapshot.data?.docs[index];
            if (transaction == null || transaction.data() == null) {
              return const ListTile(
                title: Text("Invalid transaction"),
              );
            }
            var transactionData = transaction.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              elevation: 5,
              child: ListTile(
                title: Text("\$${transactionData['amount']} - ${transactionData['type']}"),
                subtitle: Text(transactionData['note']),
                trailing: Text(transactionData['date'].toDate().toString()), // Format date as needed
              ),
            );
          },
        );
      },
    );
  }
}
