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

  // calculate number of verified lines
  int get numberOfVerifiedLines {
    int count = 0;
    for (var product in widget.productList) {
      if (product['verified']) {
        count++;
      }
    }
    return count;
  }

  bool get isCompleted {
    if (numberOfVerifiedLines == widget.productList.length) {
      return true;
    } else {
      return false;
    }
  }

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
                widget.productId,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: !isCompleted ? Colors.blueGrey : Colors.green[400]),
              ),
              subtitle: Text(
                '${widget.productList[0]['upc']}\n$numberOfVerifiedLines of ${widget.productList.length} lines completed\nCompleted: $isCompleted',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: !isCompleted ? Colors.black : Colors.green[400],
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
                                    color: widget.productList[index]['verified'] ? Colors.green[400] : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Unit ID: ${widget.productList[index]['unitId']}', style: TextStyle(color: widget.productList[index]['verified'] ? Colors.white : Colors.black),),
                                        Text('Total quantity: ${widget.productList[index]['quantity']}', style: TextStyle(color: widget.productList[index]['verified'] ? Colors.white : Colors.black),),
                                        Text('Verified: ${widget.productList[index]['verified']}', style: TextStyle(color: widget.productList[index]['verified'] ? Colors.white : Colors.black),),
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
