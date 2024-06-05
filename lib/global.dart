library globals;

import 'dart:async';

bool isDark = false;

bool registered = false;
bool isLoading = true;
String first_name = "";
String last_name = "";
String email = "";
String pass = "";
String dob = "";
String gender = "";
String avatar = "";
List<String> anamnesis = ["null"];
List<String> familyanamnesis = ["null"];

double imageMB = 0;
const double EPSILON = 1e-4;
const double limitedMB = 5.0;

String settingState = "default";
String historyState = "default";

final StreamController<String> _historyStateController = StreamController<String>.broadcast();

Stream<String> get historyStateStream => _historyStateController.stream;

void changeHistoryState(String newState) {
  historyState = newState;
  _historyStateController.add(newState);
}

void disposeHistoryStateStream() {
  _historyStateController.close();
}

Map<String, String> healthMatch = {};
Map<String, String> symptomMatch = {};
Map<String, String> anamHealthMatch = {};
Map<String, String> familyanamHealthMatch = {};

const Map<String, String> types = {
  "action" : "Biểu hiện",
  "bodyskin" : "Toàn thân - Da",
  "digest" : "Tiêu hoá",
  "ear" : "Tai",
  "excrete" : "Bài tiết",
  "eye" : "Mắt",
  "headface" : "Đầu - Mắt",
  "nerveheart" : "Thần kinh - Tim mạch",
  "nose" : "Mũi",
  "respire" : "Hô hấp",
  "throat" : "Họng"
};

const Map<String, String> healthTypes = {
  "ent" : "Tai mũi họng",
  "digest" : "Tiêu hoá",
  "respir" : "Hô hấp",
};

const Map<String, String> anamnesisTypes = {
  "bone" : "Xương",
  "breath" : "Hô hấp",
  "ennt" : "Tai mũi họng",
  "excrete" : "Bài tiết",
  "infection" : "Nhiễm trùng",
  "inflammation" : "Viêm",
  "injury" : "Chấn thương",
  "liver" : "Gan",
  "newborn" : "Sơ sinh",
  "other" : "Khác",
  "pathological" : "Bệnh lý",
  "pme" : "Đặt thiết bị y tế",
  "syndrome" : "Hội chứng"
};

const Map<String, String> familyanamnesisTypes = {
  "digestion" : "Tiêu hoá",
  "allergy" : "Dị ứng",
  "liver" : "Gan",
  "respiratory" : "Hô hấp",
  "other" : "Khác"
};