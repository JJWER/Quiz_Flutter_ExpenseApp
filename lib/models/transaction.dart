import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp

class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String type; // income or expense
  final String note;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.note,
  });

  // Method to map a Transaction object to a Firestore-compatible format
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
      'type': type,
      'note': note,
    };
  }

  // Factory method to create a Transaction from Firestore data
  factory Transaction.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Transaction(
      id: snapshot.id, // Get document ID
      amount: data['amount'],
      date: (data['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      type: data['type'],
      note: data['note'],
    );
  }
}
