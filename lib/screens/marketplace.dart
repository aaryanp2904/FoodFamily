import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../item_provider.dart';

// class Marketplace extends StatelessWidget {
//   const Marketplace({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final items = Provider.of<ItemProvider>(context).items;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Marketplace'),
//       ),
//       body: SingleChildScrollView(
//         child: DataTable(
//           columns: const [
//             DataColumn(label: Text('Name')),
//             DataColumn(label: Text('Photo')),
//             DataColumn(label: Text('Price')),
//             DataColumn(label: Text('Expiry Date')),
//           ],
//           rows: items.map((item) {
//             return DataRow(cells: [
//               DataCell(Text(item.name)),
//               DataCell(item.photos.isNotEmpty
//                   ? Image.file(
//                       item.photos[0],
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                     )
//                   : Container()),
//               DataCell(Text(item.price)),
//               DataCell(Text(item.expiryDate)),
//             ]);
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

class Marketplace extends StatelessWidget {
  const Marketplace({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context).items;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).primaryColor,
          child: Row(
            children: [
              Image.file(
                item.photos[0],
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10), // Add some space between the image and the text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(fontSize: screenWidth * 0.1), // Adjust text size
                    ),
                    SizedBox(height: 10), // Add some space between text and row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("£${item.price}"),
                        Text(item.expiryDate),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

