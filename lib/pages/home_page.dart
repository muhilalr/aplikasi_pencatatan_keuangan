import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_flutter/models/database.dart';
import 'package:project_flutter/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({super.key, required this.selectedDate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();

  String _formatCurrency(int amount) {
    return "Rp. ${amount.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    final transactions = snapshot.data!;
                    final totalIncome = transactions
                        .where((item) => item.category.type == 1)
                        .fold<int>(
                          0,
                          (total, item) => total + item.transaction.amount,
                        );
                    final totalExpense = transactions
                        .where((item) => item.category.type != 1)
                        .fold<int>(
                          0,
                          (total, item) => total + item.transaction.amount,
                        );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(
                                        Icons.download,
                                        color: Colors.green,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Income",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          _formatCurrency(totalIncome),
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(
                                        Icons.upload,
                                        color: Colors.red,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Expense",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          _formatCurrency(totalExpense),
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Transactions",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (transactions.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            await database
                                                .deleteTransactionRepo(
                                                  transactions[index]
                                                      .transaction
                                                      .id,
                                                );
                                            setState(() {});
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TransactionPage(
                                                      transactionWithCategory:
                                                          transactions[index],
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      _formatCurrency(
                                        transactions[index].transaction.amount,
                                      ),
                                    ),
                                    subtitle: Text(
                                      transactions[index].category.name +
                                          " (" +
                                          transactions[index].transaction.name +
                                          ")",
                                    ),
                                    leading: Container(
                                      child: Icon(
                                        (transactions[index].category.type == 1)
                                            ? Icons.download
                                            : Icons.upload,
                                        color:
                                            (transactions[index]
                                                    .category
                                                    .type ==
                                                1)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Center(child: Text("Data transaksi masih kosong")),
                      ],
                    );
                  } else {
                    return Center(child: Text("Tidak ada data"));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
