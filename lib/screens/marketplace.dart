import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../item_provider.dart';
import '../item_model.dart';

class Marketplace extends StatelessWidget {
  const Marketplace({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Photo')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Expiry Date')),
          ],
          rows: items.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.name)),
              DataCell(item.photos.isNotEmpty
                  ? Image.file(
                      item.photos[0],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Container()),
              DataCell(Text(item.price)),
              DataCell(Text(item.expiryDate)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
