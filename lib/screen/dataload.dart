import 'dart:io';

import 'dart:core';

import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_first_app/firebase_login/auth.dart';

import 'package:my_first_app/source/application_bloc.dart';
import 'package:my_first_app/source/constats.dart';
import 'package:my_first_app/source/datasource.dart';

import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:syncfusion_flutter_core/theme.dart';

// ignore: must_be_immutable
class DataLoadType extends StatefulWidget {
  File? data;
  DataLoadType({
    Key? key,
    required this.data,
    required this.auth,
    // required this.onSignOut,
    required this.user,
  }) : super(key: key);
  final Baseauth auth;
  // final VoidCallback onSignOut;
  final User user;

  @override
  _DataLoadTypeState createState() => _DataLoadTypeState();
}

class _DataLoadTypeState extends State<DataLoadType> {
  List<dynamic> keys = [];
  String? filtername = "";
  Map? user;
  int counter = 0;

  List<Map<String, dynamic>> json = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> templist = <Map<String, dynamic>>[];
  TextEditingController controller = TextEditingController();

  Icon customIcon = const Icon(Icons.search);

  double? lat;
  double? long;
  List<Marker> allmarker = [];
  Map<String, double> columnWidths = {};

  @override
  void initState() {
    super.initState();
  }

  Future<List> readExcelFile() async {
    var bytes = File(widget.data!.path).readAsBytesSync();

    var excel = Excel.decodeBytes(bytes);

    int i = 0;

    for (var table in excel.tables.keys) {
      if (excel.tables[table]?.rows == null) {}
      for (var row in excel.tables[table]?.rows ?? []) {
        if (i == 0) {
          keys = row;
          i++;
        } else {
          Map<String, dynamic> temp = <String, dynamic>{};
          int j = 0;
          var tk = '';
          for (var key in keys) {
            if (key == null) {
              tk = "";
            } else {
              tk = key.value;
            }

            if (row[j] == null) {
              temp[tk] = "";
            } else {
              temp[tk] = (row[j].runtimeType == String)
                  ? row[j]!.value
                  : row[j]!.value.toString();

              if (counter == 0) {
                columnWidths[tk] = double.nan;
              }
            }

            j++;
          }
          json.add(temp);
        }
      }
    }
    counter++;

    return json;
  }

  Future<List> datatble() async {
    if (filtername!.isNotEmpty) {
      for (int i = 0; i < json.length; i++) {
        for (int j = 0; j < json[i].values.toList().length; j++) {
          var item = json[i].values.toList()[j].toString();

          if (item.toLowerCase().contains("$filtername") &&
              !(templist
                  .toString()
                  .contains(json[i].values.toList()[j].toString()))) {
            templist.add(json[i]);
          }
        }
      }
    }
    return templist;
  }

  latelong(Map data) async {
    data.forEach((key, value) {
      if (key.toString().toLowerCase().contains('latitude') ||
          key.toString().toLowerCase().contains('longitude')) {
        if (key.toString().toLowerCase().contains('latitude')) {
          setState(() {
            lat = double.parse(value);
          });
        } else if (key.toString().toLowerCase().contains('longitude')) {
          setState(() {
            long = double.parse(value);
            ;
          });
        }
      }
    });

    if (lat != null && long != null) {
      allmarker.add(
        Marker(
            markerId: const MarkerId("marker"),
            draggable: false,
            onTap: () {
              print("mark tap");
            },
            position: LatLng(lat!, long!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [Container()],
          backgroundColor: kprimaryColor,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          title: Text(widget.data!.path.split('/').last.toUpperCase()),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1, right: 1),
              child: SizedBox(
                height: 50,
                child: TextField(
                  controller: controller,
                  onSubmitted: (value) {
                    //on search set in api link search  value
                    setState(() {
                      if (value.isNotEmpty) {
                        templist.clear();
                        filtername = value;
                        //clear all data only show search  relataed data
                      } else {
                        filtername = "";
                      }
                    });
                  },
                  decoration: InputDecoration(
                      fillColor: const Color(0xffF0F0F6),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.black45),
                      suffixIcon: GestureDetector(
                        child: const Icon(Icons.cancel, color: Colors.black45),
                        onTap: () {
                          setState(() {
                            controller.clear();

                            filtername = "";
                          });
                        },
                      ),
                      labelText: "Search",
                      labelStyle: GoogleFonts.montserrat(
                          color: const Color(0xffA0A0A0),
                          fontSize: 18,
                          fontWeight: FontWeight.normal),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: kprimaryColor,
                          )),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffF8F7FF)))),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                  future: filtername!.isEmpty ? readExcelFile() : datatble(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    var userdata = snapshot.data;

                    return (snapshot.hasData)
                        ? SfDataGridTheme(
                            data:
                                SfDataGridThemeData(headerColor: Colors.white),
                            child: SfDataGrid(
                                source: ExecelDataSource(json: userdata),
                                // columnWidthMode:
                                //    ,
                                allowColumnsResizing: true,
                                columnResizeMode: ColumnResizeMode.onResizeEnd,
                                onColumnResizeUpdate:
                                    (ColumnResizeUpdateDetails details) {
                                  setState(() {
                                    columnWidths[details.column.columnName] =
                                        details.width;
                                  });

                                  return true;
                                },
                                gridLinesVisibility:
                                    GridLinesVisibility.horizontal,
                                onCellTap: (details) async {
                                  int index =
                                      details.rowColumnIndex.rowIndex - 1;

                                  if (index.isNegative) {
                                    null;
                                  } else {
                                    Scaffold.of(context).openEndDrawer();

                                    setState(() {
                                      allmarker.clear();
                                      user = userdata[index];
                                    });
                                    await latelong(user!);
                                  }
                                },
                                columnWidthMode: ColumnWidthMode.auto,
                                headerRowHeight: 50,
                                allowMultiColumnSorting: true,
                                allowSorting: true,
                                allowTriStateSorting: true,
                                headerGridLinesVisibility:
                                    GridLinesVisibility.horizontal,
                                columns: List.generate(
                                    json[0].length,
                                    (index) => GridColumn(
                                        width: columnWidths[json[0]
                                            .keys
                                            .toList()[index]
                                            .toString()]!,
                                        columnName: json[0]
                                            .keys
                                            .toList()[index]
                                            .toString(),
                                        label: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            json[0]
                                                .keys
                                                .toList()[index]
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            textWidthBasis:
                                                TextWidthBasis.parent,
                                          ),
                                        )))),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
            ),
          ],
        ),
        endDrawer: Builder(
          builder: (BuildContext context) {
            final applictionBloc = Provider.of<Applicationbloc>(context);
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.95,
              child: Drawer(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: kprimaryColor,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20))),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: TextButton(
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  )),
                            ),
                            Expanded(
                              child: Text(
                                user!.values.toList()[0],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title: SelectableText(
                                        user!.keys.toList()[index],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: kprimaryColor,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: SelectableText(
                                        user!.values.toList()[index].toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  },
                                  itemCount: user!.length),
                              (lat != null && long != null)
                                  ? SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      // ignore: unnecessary_null_comparison
                                      child: (applictionBloc.currentLocation !=
                                              null)
                                          ? GoogleMap(
                                              myLocationEnabled: true,
                                              mapType: MapType.normal,
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: LatLng(lat!, long!),
                                                zoom: 12,
                                              ),
                                              markers: Set.from(allmarker),
                                            )
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }
}
