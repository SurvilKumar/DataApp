import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ExecelDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  ExecelDataSource({required List<Map<String, dynamic>> json}) {
    dataGridRows = List.generate(
        json.length,
        (index) => DataGridRow(
                cells: List.generate(
              json[0].keys.length,
              (index1) => DataGridCell(
                  columnName: json[0].keys.toList()[index1].toString(),
                  value: json[index].values.toList()[index1]),
            ))).toList();
  }
  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final int index = effectiveRows.indexOf(row);

    Color? getcolor() {
      if (index % 2 != 0) {
        return Colors.grey[300]!;
      }

      return Colors.transparent;
    }

    return DataGridRowAdapter(
        color: getcolor(),
        cells: row.getCells().map<Widget>((dataGridCell) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                dataGridCell.value.toString(),
                textAlign: TextAlign.center,
              ));
        }).toList());
  }
}
