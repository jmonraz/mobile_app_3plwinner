import 'package:flutter/material.dart';

class ProductTile extends StatefulWidget {
  final String productName;
  final int numberOfLines;
  final int totalQuantity;

  const ProductTile(
      {super.key,
      required this.productName,
      required this.numberOfLines,
      required this.totalQuantity});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(widget.productName),
              subtitle: Text('${widget.numberOfLines} lines\n${widget.totalQuantity} total'),
            ),
            if(isExpanded)
              Column(
                children: List.generate(widget.numberOfLines, (index) => ListTile(
                  title: Text('Line ${index + 1} of ${widget.numberOfLines}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total quantity: ${widget.totalQuantity}'),
                      Text('Verified? No'),
                    ],
                  ),
                  )
                ),
              ),
          ],
        ),
      ),
    );
  }
}
