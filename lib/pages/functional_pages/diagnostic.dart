import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/pages/functional_pages/display_diagnostic.dart';

class DiagnosticPage extends StatefulWidget {
  final Function()? onTap;
  final Function(List<String>)? searchMap;
  DiagnosticPage({super.key, required this.onTap, required this.searchMap});

  @override
  _DiagnosticPageState createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage>  with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List<String> tabList = [];
  List<List<bool>> checkboxValuesList = [];
  List<List<String>> checklistItemsList = [];
  List<List<String>> checkListData = [];
  List<List<String>> idData = [];
  bool isSearch = false;
  Map<String, int> mp = {};
  Map<String, bool> mark = {};
  bool ready = false;
  FocusNode _focusNode = FocusNode();
  Color _labelcolor = Colors.grey;
  List<String> results = [];
  List<bool> checkBoxValue = [];
  List<List<int>> coords = [];
  bool isDiagnose = false;
  List<dynamic> result = [];

  String? feverlevel = "Nhẹ";
  String? feverfrequen = "Không kéo dài";
  bool? feverBtnState = false;

  String? hachcolevel = "<2cm";
  bool? hachcoBtnState = false;

  String? sddlevel = "Nhẹ - Bình Thường";
  bool? sddBtnState = false;

  String? gtllevel = "<3 tháng";
  bool? gtlBtnState = false;

  String? tclevel = "Không kéo dài";
  bool? tcBtnState = false;

  String? cnmlevel = "_____________";
  bool? cnmBtnState = false;

  String? nmclevel = "đục, xanh";
  bool? nmcBtnState = false;

  String? cntlevel = "kéo dài";
  bool? cntBtnState = false;

  void toggleCheckbox(int tabIndex, int itemIndex, bool value) {
    setState(() {
      checkboxValuesList[tabIndex][itemIndex] = value;
      if (tabIndex == 2 && itemIndex == 2 && value == false){
        for (int i = 3;i<=10;++i) checkboxValuesList[2][i] = false;
      }
      if (tabIndex == 2 && 3 <= itemIndex && itemIndex <= 10 && value == true){
        checkboxValuesList[2][2] = true;
      }

      if (tabIndex == 9 && itemIndex == 4 && value == false){
        checkboxValuesList[9][5] = false;
      }
      if (tabIndex == 9 && itemIndex == 5 && value == true){
        checkboxValuesList[9][4] = true;
      }

      if (tabIndex == 9 && itemIndex == 6 && value == false){
        checkboxValuesList[9][7] = false;
      }
      if (tabIndex == 9 && itemIndex == 7 && value == true){
        checkboxValuesList[9][6] = true;
      }
    });
  }

  void diagnose() async {
    List<String> symptoms = [];
    for (int i = 0; i < checklistItemsList.length; ++i){
      for (int j = 0; j < checklistItemsList[i].length; ++j){
        if (checkboxValuesList[i][j] ){
          symptoms.add(idData[i][j]);
        }
      }
    }
    int len = symptoms.length, t = 0;
    if (symptoms.contains("bodyskin01")) ++t;
    if (symptoms.contains("bodyskin02")) ++t;
    if (symptoms.contains("bodyskin03")) ++t;
    if (symptoms.contains("bodyskin08")) ++t;
    if (t > 0) len -= t-1;
    if (symptoms.contains("bodyskin12")) --len;
    if (symptoms.contains("bodyskin29")) --len;
    if (symptoms.contains("ear10")) --len;
    if (symptoms.contains("excrete05")) --len;
    if (symptoms.contains("nose03")) --len;
    if (symptoms.contains("respire02")) --len;
    if (symptoms.contains("respire03")) --len;
    // print(symptoms);

    if(len < 3){
      showMessage("Bạn cần chọn ít nhất nhất 3 triệu chứng!"); return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );

    final url = Uri.parse('https://healerai.elifeup.com/diagnostic');

    final payload = {
      "symptoms": symptoms,
      "anamnesis": globals.anamnesis,
      "familyanamnesis": globals.familyanamnesis
    };
    // print(globals.familyanamnesis);

    final headers = {
      "Content-Type": "application/json",
      "token": "super_secret_token"
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );
    
    if (response.statusCode == 200) {
      result = json.decode(response.body)["health_problems"];
      int id;
      String symp = "", res = "";
      bool isVertify = false;
      for (String symptom in symptoms){
        symp+=symptom; symp += ",";
      }
      for (String health in result){
        res+=health; res += ",";
      }
      symp = symp.substring(0,symp.length-1);
      res = res.substring(0,res.length-1);
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("identify")
        .doc("current-id")
        .get();
      id = documentSnapshot.get("id") + 1;
      print(id);
      await FirebaseFirestore.instance
        .collection("identify")
        .doc("current-id")
        .update({
          "id" : id
        });
      
      await FirebaseFirestore.instance
        .collection("users")
        .doc(globals.email)
        .collection("diagnostic-history")
        .add({
          "id" : id,
          "symptoms" : symp,
          "result" : res,
          "isVertify" : isVertify
        });
      Navigator.pop(context);
      setState(() {
        isDiagnose = true;
      });
    } else {
      print("Request failed with status code: ${response.statusCode}");
      print("Response: ${response.body}");
      Navigator.pop(context);
      showMessage("Có lỗi xảy ra, vui lòng thử lại sau!");
    }
  }

  void showMessage(String mess){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 20, 80, 139),
          title: Center(
            child: Text(
              mess,
              style: const TextStyle(color: Colors.white, fontSize: 18)
            )
          )
        );
      }
    );
  }

  @override
  void initState(){
    super.initState();
    ready = false;
    _focusNode = FocusNode();
    _labelcolor = Colors.grey;

    _focusNode.addListener((){
      setState(() {
        _labelcolor = _focusNode.hasFocus ? Color(0xff228af4) : Colors.grey;
      });
    });
    

    fetchNames().then((_) {
      checklistItemsList = checkListData;
      _tabController = TabController(length: checklistItemsList.length, vsync: this);
      checkboxValuesList = List.generate(
        checklistItemsList.length,
        (outerIndex) => List.generate(
          checklistItemsList[outerIndex].length,
          (innerIndex) => false,
        ),
      );
      // print(idData);
      setState((){
        ready = true;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchNames() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('symptom');
    QuerySnapshot querySnapshot = await collectionReference.get();

    int index = 0;
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id'] as String;
      String name = data['name'] as String;
      String type = id.substring(0, ffnci(id));
      if (mp[type] == null){
        mp[type] = index;
        index++;
        checkListData.add([]);
        idData.add([]);
        tabList.add(globals.types[type]!);
      }
      if (mark[toTitle(name)] == null){
        checkListData[mp[type]!].add(toTitle(name));
        idData[mp[type]!].add(id);
        mark[toTitle(name)] = true;
      }
      return [id, name];
    }).toList();
  }

  int ffnci(String str) {
    for (int i = 0; i < str.length; i++) {
      if (isDigit(str[i])) {
        return i;
      }
    }
    return -1;
  }

  bool isDigit(String character) {
    return RegExp(r'^[0-9]$').hasMatch(character);
  }

  String toTitle(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    if (ready){
      if(isDiagnose) return DisplayDiagnostic(results: result,  onTap: widget.onTap, searchMap: widget.searchMap,);
      else return Column(
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
                style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18),
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: "Tìm kiếm",
                  suffixIcon: Icon(Icons.search, color: Colors.grey[400]!, size: 30),
                  labelStyle: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18, color: _labelcolor),
                ),
                cursorColor: Colors.grey,
                onChanged: (text) {
                  setState(() {
                    if (text == ""){
                      isSearch = false;
                      results = [];
                      checkBoxValue = [];
                      coords = [];
                    }
                    else{
                      isSearch = true;
                      results = [];
                      checkBoxValue = [];
                      coords = [];
                      String task = text.toLowerCase();
                      for (int i = 0;i< checklistItemsList.length;++i){
                        for (int j = 0;j<checklistItemsList[i].length;++j){
                          if (checklistItemsList[i][j].toLowerCase().contains(task)){
                            results.add(checklistItemsList[i][j]);
                            checkBoxValue.add(checkboxValuesList[i][j]);
                            coords.add([i, j]);
                          }
                        }
                      }
                    }
                  });
                },
            ),
          ),

           SizedBox(height: 20),

          if(!isSearch) Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                labelStyle: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1800)  : 17),
                isScrollable: true,
                tabs: List.generate(
                  checklistItemsList.length,
                  (index) => Tab(text: tabList[index]),
                ),
              ),
            ),
          ),

          if(!isSearch) Expanded(child:Container(
            width: double.maxFinite,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  checklistItemsList.length,
                  (tabIndex) => ListView.builder(
                    itemCount: checklistItemsList[tabIndex].length,
                    itemBuilder: (context, itemIndex) {
                      if (tabIndex == 1 && itemIndex == 0) return CheckboxListTile(
                        value: feverBtnState,
                        onChanged: (value) {
                          setState(() {
                            feverBtnState = value;
                            if (feverBtnState == false){
                              checkboxValuesList[1][0] = false;
                              checkboxValuesList[1][1] = false;
                              checkboxValuesList[1][2] = false;
                              checkboxValuesList[1][3] = false;
                            } else{
                              checkboxValuesList[1][0] = true;
                              if (feverlevel == "Nhẹ") checkboxValuesList[1][2] = true;
                              else checkboxValuesList[1][1] = true;

                              if (feverfrequen == "Kéo dài") checkboxValuesList[1][3] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: feverlevel,
                              items: ["Nhẹ", "Cao"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  feverlevel = newValue;
                                  if (feverBtnState == true){
                                    if (feverlevel == "Nhẹ"){
                                      checkboxValuesList[1][1] = false;
                                      checkboxValuesList[1][2] = true;
                                    }
                                    else{
                                      checkboxValuesList[1][1] = true;
                                      checkboxValuesList[1][2] = false;
                                    }
                                  }
                                });
                              },
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: feverfrequen,
                              items: ["Không kéo dài", "Kéo dài"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  feverfrequen = newValue;
                                  if (feverBtnState == true){
                                    if (feverfrequen == "Không kéo dài"){
                                      checkboxValuesList[1][3] = false;
                                    }
                                    else{
                                      checkboxValuesList[1][3] = true;
                                    }
                                  }
                                });
                              },
                            )
                          ],
                        )
                      );
                      else if(tabIndex == 1 && itemIndex == 6) return CheckboxListTile(
                        value: hachcoBtnState,
                        onChanged: (value) {
                          setState(() {
                            hachcoBtnState = value;
                            if (hachcoBtnState == false){
                              checkboxValuesList[1][6] = false;
                              checkboxValuesList[1][7] = false;
                            } else{
                              checkboxValuesList[1][6] = true;
                              if (hachcolevel == ">2cm") checkboxValuesList[1][7] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: hachcolevel,
                              items: ["<2cm", ">2cm"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  hachcolevel = newValue;
                                  if (hachcoBtnState == true){
                                    if (hachcolevel == "<2cm"){
                                      checkboxValuesList[1][7] = false;
                                    }
                                    else{
                                      checkboxValuesList[1][7] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 1 && itemIndex == 22) return CheckboxListTile(
                        value: sddBtnState,
                        onChanged: (value) {
                          setState(() {
                            sddBtnState = value;
                            if (sddBtnState == false){
                              checkboxValuesList[1][22] = false;
                              checkboxValuesList[1][23] = false;
                            } else{
                              checkboxValuesList[1][22] = true;
                              if (sddlevel == "Nặng") checkboxValuesList[1][23] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: sddlevel,
                              items: ["Nhẹ - Bình Thường", "Nặng"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  sddlevel = newValue;
                                  if (sddBtnState == true){
                                    if (sddlevel == "Nhẹ - Bình Thường"){
                                      checkboxValuesList[1][23] = false;
                                    }
                                    else{
                                      checkboxValuesList[1][23] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 3 && itemIndex == 8) return CheckboxListTile(
                        value: gtlBtnState,
                        onChanged: (value) {
                          setState(() {
                            gtlBtnState = value;
                            if (gtlBtnState == false){
                              checkboxValuesList[3][8] = false;
                              checkboxValuesList[3][9] = false;
                            } else{
                              checkboxValuesList[3][8] = true;
                              if (gtllevel == ">=3 tháng") checkboxValuesList[3][9] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: gtllevel,
                              items: ["<3 tháng", ">=3 tháng"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  gtllevel = newValue;
                                  if (gtlBtnState == true){
                                    if (gtllevel == "<3 tháng"){
                                      checkboxValuesList[3][9] = false;
                                    }
                                    else{
                                      checkboxValuesList[3][9] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 4 && itemIndex == 0) return CheckboxListTile(
                        value: tcBtnState,
                        onChanged: (value) {
                          setState(() {
                            tcBtnState = value;
                            if (tcBtnState == false){
                              checkboxValuesList[4][0] = false;
                              checkboxValuesList[4][1] = false;
                            } else{
                              checkboxValuesList[4][0] = true;
                              if (tclevel == "Kéo dài") checkboxValuesList[4][1] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: tclevel,
                              items: ["Không kéo dài", "Kéo dài"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  tclevel = newValue;
                                  if (tcBtnState == true){
                                    if (tclevel == "Không kéo dài"){
                                      checkboxValuesList[4][1] = false;
                                    }
                                    else{
                                      checkboxValuesList[4][1] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 8 && itemIndex == 1) return CheckboxListTile(
                        value: cnmBtnState,
                        onChanged: (value) {
                          setState(() {
                            cnmBtnState = value;
                            if (cnmBtnState == false){
                              checkboxValuesList[8][1] = false;
                              checkboxValuesList[8][2] = false;
                            } else{
                              checkboxValuesList[8][1] = true;
                              if (cnmlevel == "Xanh tái phát") checkboxValuesList[8][2] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: cnmlevel,
                              items: ["_____________", "Xanh tái phát"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  cnmlevel = newValue;
                                  if (cnmBtnState == true){
                                    if (cnmlevel == "_____________"){
                                      checkboxValuesList[8][2] = false;
                                    }
                                    else{
                                      checkboxValuesList[8][2] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 8 && itemIndex == 5) return CheckboxListTile(
                        value: nmcBtnState,
                        onChanged: (value) {
                          setState(() {
                            nmcBtnState = value;
                            if (nmcBtnState == false){
                              checkboxValuesList[8][5] = false;
                              checkboxValuesList[8][6] = false;
                            } else{
                              if (nmclevel == "đục, xanh") checkboxValuesList[8][5] = true;
                              else if (nmclevel == "vàng, xanh") checkboxValuesList[8][6] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              "Nước mũi có màu",
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: nmclevel,
                              items: ["đục, xanh", "vàng, xanh"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  nmclevel = newValue;
                                  if (nmcBtnState == true){
                                    if (nmclevel == "đục, xanh"){
                                      checkboxValuesList[8][5] = true;
                                      checkboxValuesList[8][6] = false;
                                    }
                                    else if (nmclevel == "vàng, xanh"){
                                      checkboxValuesList[8][5] = false;
                                      checkboxValuesList[8][6] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 9 && itemIndex == 0) return CheckboxListTile(
                        value: cntBtnState,
                        onChanged: (value) {
                          setState(() {
                            cntBtnState = value;
                            if (cntBtnState == false){
                              checkboxValuesList[9][0] = false;
                              checkboxValuesList[9][1] = false;
                              checkboxValuesList[9][2] = false;
                            } else{
                              checkboxValuesList[9][0] = true;
                              print(cntlevel);
                              if (cntlevel == "kéo dài") checkboxValuesList[9][1] = true;
                              else if (cntlevel == "ngắn") checkboxValuesList[9][2] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: cntlevel,
                              items: ["kéo dài", "ngắn"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  cntlevel = newValue;
                                  if (cntBtnState == true){
                                    if (cntlevel == "kéo dài"){
                                      checkboxValuesList[9][1] = true;
                                      checkboxValuesList[9][2] = false;
                                    }
                                    else if (cntlevel == "ngắn"){
                                      checkboxValuesList[9][1] = false;
                                      checkboxValuesList[9][2] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if (tabIndex == 1 && (itemIndex == 1 || itemIndex == 2 || itemIndex == 3 || itemIndex == 7 || itemIndex == 23)) return SizedBox();
                      else if (tabIndex == 3 && itemIndex == 9) return SizedBox();
                      else if (tabIndex == 4 && itemIndex == 1) return SizedBox();
                      else if (tabIndex == 8 && (itemIndex == 2 || itemIndex == 6)) return SizedBox();
                      else if (tabIndex == 9 && (itemIndex == 1 || itemIndex == 2)) return SizedBox();
                      else return CheckboxListTile(
                        value: checkboxValuesList[tabIndex][itemIndex],
                        onChanged: (value) {
                          toggleCheckbox(tabIndex, itemIndex, value ?? false);
                        },
                        title: Text(
                          checklistItemsList[tabIndex][itemIndex],
                          style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                        ),
                      );
                    },
                  ),
                )
                
              ),
            ),
          )),

          if (isSearch)
          Expanded(
            child: (results.length != 0) ? ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                int tabIndex = coords[index][0];
                int itemIndex = coords[index][1];
                if (tabIndex == 1 && itemIndex == 0) return CheckboxListTile(
                        value: feverBtnState,
                        onChanged: (value) {
                          setState(() {
                            feverBtnState = value;
                            if (feverBtnState == false){
                              checkboxValuesList[1][0] = false;
                              checkboxValuesList[1][1] = false;
                              checkboxValuesList[1][2] = false;
                              checkboxValuesList[1][3] = false;
                            } else{
                              checkboxValuesList[1][0] = true;
                              if (feverlevel == "Nhẹ") checkboxValuesList[1][2] = true;
                              else checkboxValuesList[1][1] = true;

                              if (feverfrequen == "Kéo dài") checkboxValuesList[1][3] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: feverlevel,
                              items: ["Nhẹ", "Cao"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  feverlevel = newValue;
                                  if (feverBtnState == true){
                                    if (feverlevel == "Nhẹ"){
                                      checkboxValuesList[1][1] = false;
                                      checkboxValuesList[1][2] = true;
                                    }
                                    else{
                                      checkboxValuesList[1][1] = true;
                                      checkboxValuesList[1][2] = false;
                                    }
                                  }
                                });
                              },
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: feverfrequen,
                              items: ["Không kéo dài", "Kéo dài"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  feverfrequen = newValue;
                                  if (feverBtnState == true){
                                    if (feverfrequen == "Không kéo dài"){
                                      checkboxValuesList[1][3] = false;
                                    }
                                    else{
                                      checkboxValuesList[1][3] = true;
                                    }
                                  }
                                });
                              },
                            )
                          ],
                        )
                      );
                      else if(tabIndex == 1 && itemIndex == 6) return CheckboxListTile(
                        value: hachcoBtnState,
                        onChanged: (value) {
                          setState(() {
                            hachcoBtnState = value;
                            if (hachcoBtnState == false){
                              checkboxValuesList[1][6] = false;
                              checkboxValuesList[1][7] = false;
                            } else{
                              checkboxValuesList[1][6] = true;
                              if (hachcolevel == ">2cm") checkboxValuesList[1][7] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: hachcolevel,
                              items: ["<2cm", ">2cm"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  hachcolevel = newValue;
                                  if (hachcoBtnState == true){
                                    if (hachcolevel == "<2cm"){
                                      checkboxValuesList[1][7] = false;
                                    }
                                    else{
                                      checkboxValuesList[1][7] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 1 && itemIndex == 22) return CheckboxListTile(
                        value: sddBtnState,
                        onChanged: (value) {
                          setState(() {
                            sddBtnState = value;
                            if (sddBtnState == false){
                              checkboxValuesList[1][22] = false;
                              checkboxValuesList[1][23] = false;
                            } else{
                              checkboxValuesList[1][22] = true;
                              if (sddlevel == "Nặng") checkboxValuesList[1][23] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: sddlevel,
                              items: ["Nhẹ - Bình Thường", "Nặng"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  sddlevel = newValue;
                                  if (sddBtnState == true){
                                    if (sddlevel == "Nhẹ - Bình Thường"){
                                      checkboxValuesList[1][23] = false;
                                    }
                                    else{
                                      checkboxValuesList[1][23] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 3 && itemIndex == 8) return CheckboxListTile(
                        value: gtlBtnState,
                        onChanged: (value) {
                          setState(() {
                            gtlBtnState = value;
                            if (gtlBtnState == false){
                              checkboxValuesList[3][8] = false;
                              checkboxValuesList[3][9] = false;
                            } else{
                              checkboxValuesList[3][8] = true;
                              if (gtllevel == ">=3 tháng") checkboxValuesList[3][9] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: gtllevel,
                              items: ["<3 tháng", ">=3 tháng"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  gtllevel = newValue;
                                  if (gtlBtnState == true){
                                    if (gtllevel == "<3 tháng"){
                                      checkboxValuesList[3][9] = false;
                                    }
                                    else{
                                      checkboxValuesList[3][9] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 4 && itemIndex == 0) return CheckboxListTile(
                        value: tcBtnState,
                        onChanged: (value) {
                          setState(() {
                            tcBtnState = value;
                            if (tcBtnState == false){
                              checkboxValuesList[4][0] = false;
                              checkboxValuesList[4][1] = false;
                            } else{
                              checkboxValuesList[4][0] = true;
                              if (tclevel == "Kéo dài") checkboxValuesList[4][1] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: tclevel,
                              items: ["Không kéo dài", "Kéo dài"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  tclevel = newValue;
                                  if (tcBtnState == true){
                                    if (tclevel == "Không kéo dài"){
                                      checkboxValuesList[4][1] = false;
                                    }
                                    else{
                                      checkboxValuesList[4][1] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 8 && itemIndex == 1) return CheckboxListTile(
                        value: cnmBtnState,
                        onChanged: (value) {
                          setState(() {
                            cnmBtnState = value;
                            if (cnmBtnState == false){
                              checkboxValuesList[8][1] = false;
                              checkboxValuesList[8][2] = false;
                            } else{
                              checkboxValuesList[8][1] = true;
                              if (cnmlevel == "Xanh tái phát") checkboxValuesList[8][2] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: cnmlevel,
                              items: ["_____________", "Xanh tái phát"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  cnmlevel = newValue;
                                  if (cnmBtnState == true){
                                    if (cnmlevel == "_____________"){
                                      checkboxValuesList[8][2] = false;
                                    }
                                    else{
                                      checkboxValuesList[8][2] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 8 && itemIndex == 5) return CheckboxListTile(
                        value: nmcBtnState,
                        onChanged: (value) {
                          setState(() {
                            nmcBtnState = value;
                            if (nmcBtnState == false){
                              checkboxValuesList[8][5] = false;
                              checkboxValuesList[8][6] = false;
                            } else{
                              if (nmclevel == "đục, xanh") checkboxValuesList[8][5] = true;
                              else if (nmclevel == "vàng, xanh") checkboxValuesList[8][6] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              "Nước mũi có màu",
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: nmclevel,
                              items: ["đục, xanh", "vàng, xanh"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  nmclevel = newValue;
                                  if (nmcBtnState == true){
                                    if (nmclevel == "đục, xanh"){
                                      checkboxValuesList[8][5] = true;
                                      checkboxValuesList[8][6] = false;
                                    }
                                    else if (nmclevel == "vàng, xanh"){
                                      checkboxValuesList[8][5] = false;
                                      checkboxValuesList[8][6] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if(tabIndex == 9 && itemIndex == 0) return CheckboxListTile(
                        value: cntBtnState,
                        onChanged: (value) {
                          setState(() {
                            cntBtnState = value;
                            if (cntBtnState == false){
                              checkboxValuesList[9][0] = false;
                              checkboxValuesList[9][1] = false;
                              checkboxValuesList[9][2] = false;
                            } else{
                              checkboxValuesList[9][0] = true;
                              print(cntlevel);
                              if (cntlevel == "kéo dài") checkboxValuesList[9][1] = true;
                              else if (cntlevel == "ngắn") checkboxValuesList[9][2] = true;
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                            ),
                            SizedBox(width:20),
                            DropdownButton<String>(
                              value: cntlevel,
                              items: ["kéo dài", "ngắn"].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  cntlevel = newValue;
                                  if (cntBtnState == true){
                                    if (cntlevel == "kéo dài"){
                                      checkboxValuesList[9][1] = true;
                                      checkboxValuesList[9][2] = false;
                                    }
                                    else if (cntlevel == "ngắn"){
                                      checkboxValuesList[9][1] = false;
                                      checkboxValuesList[9][2] = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      );
                      else if (tabIndex == 1 && (itemIndex == 1 || itemIndex == 2 || itemIndex == 3 || itemIndex == 7 || itemIndex == 23)) return SizedBox();
                      else if (tabIndex == 3 && itemIndex == 9) return SizedBox();
                      else if (tabIndex == 4 && itemIndex == 1) return SizedBox();
                      else if (tabIndex == 8 && (itemIndex == 2 || itemIndex == 6)) return SizedBox();
                      else if (tabIndex == 9 && (itemIndex == 1 || itemIndex == 2)) return SizedBox();
                else return CheckboxListTile(
                  value: checkboxValuesList[coords[index][0]][coords[index][1]],
                  onChanged: (value) {
                    setState(() {
                      checkBoxValue[index] = value ?? false;
                      var coord = coords[index];
                      checkboxValuesList[coord[0]][coord[1]] = value ?? false;
                      if (coord[0] == 2 && coord[1] == 2 && value == false){
                        for (int i = 3;i<=10;++i) checkboxValuesList[2][i] = false;
                      }
                      if (coord[0] == 2 && 3 <= coord[1] && coord[1] <= 10 && value == true){
                        checkboxValuesList[2][2] = true;
                      }

                      if (coord[0] == 9 && coord[1] == 4 && value == false){
                        checkboxValuesList[9][5] = false;
                      }
                      if (coord[0] == 9 && coord[1] == 5 && value == true){
                        checkboxValuesList[9][4] = true;
                      }

                      if (tabIndex == 9 && itemIndex == 6 && value == false){
                        checkboxValuesList[9][7] = false;
                      }
                      if (tabIndex == 9 && itemIndex == 7 && value == true){
                        checkboxValuesList[9][6] = true;
                      }
                    });
                  },
                  title: Text(
                    results[index],
                    style: TextStyle(
                      fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600) / 1000) : 17,
                    ),
                  ),
                );
              },
            ) : Center(
              child: Container(
                child: Text(
                  "Không tìm thấy kết quả",
                  style: TextStyle(fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600) / 1000) : 20),
                ),
              )
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 10, top: 15),
            child: MyButton(
              text: "Chẩn đoán",
              onTap: diagnose,
            )
          )
        ],
      );
    }
    else return Center(child: CircularProgressIndicator());
  }
}