import 'package:flutter/material.dart';

class ProductTile extends StatefulWidget {
  final String productId;
  final List productList;

  const ProductTile(
      {super.key, required this.productId, required this.productList});

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
              title: Text(
                '${widget.productId}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.blueGrey),
              ),
              subtitle: Text(
                '0 of ${widget.productList.length} lines completed',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isExpanded)
              Column(
                children: List.generate(
                    widget.productList.length,
                    (index) => ListTile(
                          title: Text('Line ${index + 1} of ${widget.productList.length}',
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blueGrey),
                                    color: widget.productList[index]['verified'] ? Colors.green : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Unit ID: ${widget.productList[index]['unitId']}'),
                                        Text('Total quantity: ${widget.productList[index]['quantity']}'),
                                        Text('Verified: ${widget.productList[index]['verified']}'),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        )),
              ),
          ],
        ),
      ),
    );
  }
}