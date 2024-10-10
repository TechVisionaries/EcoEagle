import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';

class WasteAssistant extends StatefulWidget {
  const WasteAssistant({super.key});

  @override
  _WasteAssistantState createState() => _WasteAssistantState();
}

class _WasteAssistantState extends State<WasteAssistant> {
  final messageInsert = TextEditingController();
  List<Map> messages = [];
  String? selectedLanguage;
  bool isGreetingDisplayed = false;

  void handleInput(String input) {
    // Insert the user's message as a user bubble
    setState(() {
      messages.insert(0, {"data": 1, "message": input});
    });

    if (!isGreetingDisplayed) {
      setState(() {
        messages.insert(0, {
          "data": 0,
          "message":
              "Welcome to EcoEagle. My name is EWA, your waste assistant."
        });
        messages.insert(0, {
          "data": 0,
          "message":
              "Please select your language: \n1) English \n2) Sinhala \n3) Tamil"
        });
        isGreetingDisplayed = true;
      });
      return;
    }

    if (selectedLanguage == null) {
      if (input == '1') {
        selectedLanguage = 'English';
        displayEnglishMenu();
      } else if (input == '2') {
        selectedLanguage = 'Sinhala';
        displaySinhalaMenu();
      } else if (input == '3') {
        selectedLanguage = 'Tamil';
        displayTamilMenu();
      } else {
        addMessage("Invalid selection. Please choose a valid language option.");
        messages.insert(0, {
          "data": 0,
          "message":
              "Please select your language: \n1) English \n2) Sinhala \n3) Tamil"
        });
      }
    } else {
      handleLanguageCommands(input);
    }
  }

  void displayEnglishMenu() {
    setState(() {
      messages.insert(0, {
        "data": 0,
        "message": "You have selected English. Here are your options:\n"
            "1) How to make an appointment\n"
            "2) How to check my appointments\n"
            "3) How to remove my appointment\n"
            "4) How to rate my driver\n"
            "5) Exit"
      });
    });
  }

  void displaySinhalaMenu() {
    setState(() {
      messages.insert(0, {
        "data": 0,
        "message":
            "ඔබ සිංහල භාෂාව තේරී ඇති අතර, පහත ඇති විකල්ප වලින් යමක් තෝරන්න:\n"
                "1) කටයුතු සැලසුම් කරන්නේ කෙසේද\n"
                "2) මාගේ කටයුතු පරීක්ෂා කළ හැකිද\n"
                "3) මාගේ කටයුතු අහෝසි කරන්නේ කෙසේද\n"
                "4) මාගේ රියදුරාට අනුග්‍රහය ලබාදීම\n"
                "5) නතර කරන්න"
      });
    });
  }

  void displayTamilMenu() {
    setState(() {
      messages.insert(0, {
        "data": 0,
        "message":
            "நீங்கள் தமிழ் மொழியை தேர்வு செய்துள்ளீர்கள். உங்கள் விருப்பங்களைத் தேர்ந்தெடுக்கவும்:\n"
                "1) நியமனம் செய்ய எப்படி\n"
                "2) எனது நியமனங்களை எப்படி பார்க்க வேண்டும்\n"
                "3) எனது நியமனத்தை எப்படி அகற்றுவது\n"
                "4) எனது இயக்குனரை மதிப்பீடு செய்யவும்\n"
                "5) வெளியேறு"
      });
    });
  }

  void handleLanguageCommands(String input) {
    switch (selectedLanguage) {
      case 'English':
        if (input == '1') {
          addMessage("To make an appointment, please contact our support.");
          messages.insert(0, {
            "data": 0,
            "message": "You have selected English. Here are your options:\n"
                "1) How to make an appointment\n"
                "2) How to check my appointments\n"
                "3) How to remove my appointment\n"
                "4) How to rate my driver\n"
                "5) Exit"
          });
        } else if (input == '2') {
          addMessage("You can check your appointments in the app.");
          messages.insert(0, {
            "data": 0,
            "message": "You have selected English. Here are your options:\n"
                "1) How to make an appointment\n"
                "2) How to check my appointments\n"
                "3) How to remove my appointment\n"
                "4) How to rate my driver\n"
                "5) Exit"
          });
        } else if (input == '3') {
          addMessage(
              "To remove your appointment, please go to your appointments list.");
          messages.insert(0, {
            "data": 0,
            "message": "You have selected English. Here are your options:\n"
                "1) How to make an appointment\n"
                "2) How to check my appointments\n"
                "3) How to remove my appointment\n"
                "4) How to rate my driver\n"
                "5) Exit"
          });
        } else if (input == '4') {
          addMessage("You can rate your driver in the app after your ride.");
          messages.insert(0, {
            "data": 0,
            "message": "You have selected English. Here are your options:\n"
                "1) How to make an appointment\n"
                "2) How to check my appointments\n"
                "3) How to remove my appointment\n"
                "4) How to rate my driver\n"
                "5) Exit"
          });
        } else if (input == '5') {
          resetAssistant();
        } else {
          addMessage("Invalid selection. Please choose a valid option.");
          messages.insert(0, {
            "data": 0,
            "message": "You have selected English. Here are your options:\n"
                "1) How to make an appointment\n"
                "2) How to check my appointments\n"
                "3) How to remove my appointment\n"
                "4) How to rate my driver\n"
                "5) Exit"
          });
        }
        break;

      case 'Sinhala':
        if (input == '1') {
          addMessage(
              "කටයුතු සැලසුම් කිරීම සඳහා, කරුණාකර අපගේ සහය වාර්තා කරන්න.");
          messages.insert(0, {
            "data": 0,
            "message":
                "ඔබ සිංහල භාෂාව තේරී ඇති අතර, පහත ඇති විකල්ප වලින් යමක් තෝරන්න:\n"
                    "1) කටයුතු සැලසුම් කරන්නේ කෙසේද\n"
                    "2) මාගේ කටයුතු පරීක්ෂා කළ හැකිද\n"
                    "3) මාගේ කටයුතු අහෝසි කරන්නේ කෙසේද\n"
                    "4) මාගේ රියදුරාට අනුග්‍රහය ලබාදීම\n"
                    "5) නතර කරන්න"
          });
        } else if (input == '2') {
          addMessage("ඔබගේ කටයුතු අපේ යෙදුම තුල පරීක්ෂා කළ හැක.");
          messages.insert(0, {
            "data": 0,
            "message":
                "ඔබ සිංහල භාෂාව තේරී ඇති අතර, පහත ඇති විකල්ප වලින් යමක් තෝරන්න:\n"
                    "1) කටයුතු සැලසුම් කරන්නේ කෙසේද\n"
                    "2) මාගේ කටයුතු පරීක්ෂා කළ හැකිද\n"
                    "3) මාගේ කටයුතු අහෝසි කරන්නේ කෙසේද\n"
                    "4) මාගේ රියදුරාට අනුග්‍රහය ලබාදීම\n"
                    "5) නතර කරන්න"
          });
        } else if (input == '3') {
          addMessage(
              "ඔබේ කටයුතු අහෝසි කිරීමට, කරුණාකර ඔබේ කටයුතු ලැයිස්තුවට යන්න.");
          messages.insert(0, {
            "data": 0,
            "message":
                "ඔබ සිංහල භාෂාව තේරී ඇති අතර, පහත ඇති විකල්ප වලින් යමක් තෝරන්න:\n"
                    "1) කටයුතු සැලසුම් කරන්නේ කෙසේද\n"
                    "2) මාගේ කටයුතු පරීක්ෂා කළ හැකිද\n"
                    "3) මාගේ කටයුතු අහෝසි කරන්නේ කෙසේද\n"
                    "4) මාගේ රියදුරාට අනුග්‍රහය ලබාදීම\n"
                    "5) නතර කරන්න"
          });
        } else if (input == '4') {
          addMessage("ඔබේ රියදුරාට අනුග්‍රහය ලබා දිය හැක.");
          messages.insert(0, {
            "data": 0,
            "message":
                "ඔබ සිංහල භාෂාව තේරී ඇති අතර, පහත ඇති විකල්ප වලින් යමක් තෝරන්න:\n"
                    "1) කටයුතු සැලසුම් කරන්නේ කෙසේද\n"
                    "2) මාගේ කටයුතු පරීක්ෂා කළ හැකිද\n"
                    "3) මාගේ කටයුතු අහෝසි කරන්නේ කෙසේද\n"
                    "4) මාගේ රියදුරාට අනුග්‍රහය ලබාදීම\n"
                    "5) නතර කරන්න"
          });
        } else if (input == '5') {
          resetAssistant();
        } else {
          addMessage("වැරදි තේරීමක්. කරුණාකර හොඳ පිළිතුරක් තෝරන්න.");
          messages.insert(0, {
            "data": 0,
            "message":
                "ඔබ සිංහල භාෂාව තේරී ඇති අතර, පහත ඇති විකල්ප වලින් යමක් තෝරන්න:\n"
                    "1) කටයුතු සැලසුම් කරන්නේ කෙසේද\n"
                    "2) මාගේ කටයුතු පරීක්ෂා කළ හැකිද\n"
                    "3) මාගේ කටයුතු අහෝසි කරන්නේ කෙසේද\n"
                    "4) මාගේ රියදුරාට අනුග්‍රහය ලබාදීම\n"
                    "5) නතර කරන්න"
          });
        }
        break;

      case 'Tamil':
        if (input == '1') {
          addMessage(
              "அனைத்தும் நியமனம் செய்ய, தயவுசெய்து எங்கள் ஆதரவை தொடர்பு கொள்ளவும்.");
          messages.insert(0, {
            "data": 0,
            "message":
                "நீங்கள் தமிழ் மொழியை தேர்வு செய்துள்ளீர்கள். உங்கள் விருப்பங்களைத் தேர்ந்தெடுக்கவும்:\n"
                    "1) நியமனம் செய்ய எப்படி\n"
                    "2) எனது நியமனங்களை எப்படி பார்க்க வேண்டும்\n"
                    "3) எனது நியமனத்தை எப்படி அகற்றுவது\n"
                    "4) எனது இயக்குனரை மதிப்பீடு செய்யவும்\n"
                    "5) வெளியேறு"
          });
        } else if (input == '2') {
          addMessage(
              "உங்கள் நியமனங்களைப் பார்க்க, தயவுசெய்து பயன்பாட்டில் செல்லவும்.");
          messages.insert(0, {
            "data": 0,
            "message":
                "நீங்கள் தமிழ் மொழியை தேர்வு செய்துள்ளீர்கள். உங்கள் விருப்பங்களைத் தேர்ந்தெடுக்கவும்:\n"
                    "1) நியமனம் செய்ய எப்படி\n"
                    "2) எனது நியமனங்களை எப்படி பார்க்க வேண்டும்\n"
                    "3) எனது நியமனத்தை எப்படி அகற்றுவது\n"
                    "4) எனது இயக்குனரை மதிப்பீடு செய்யவும்\n"
                    "5) வெளியேறு"
          });
        } else if (input == '3') {
          addMessage(
              "உங்கள் நியமனத்தை அகற்ற, உங்கள் நியமனத்தினை பார்த்து கடைசி முடிவுகள் செய்யவும்.");
          messages.insert(0, {
            "data": 0,
            "message":
                "நீங்கள் தமிழ் மொழியை தேர்வு செய்துள்ளீர்கள். உங்கள் விருப்பங்களைத் தேர்ந்தெடுக்கவும்:\n"
                    "1) நியமனம் செய்ய எப்படி\n"
                    "2) எனது நியமனங்களை எப்படி பார்க்க வேண்டும்\n"
                    "3) எனது நியமனத்தை எப்படி அகற்றுவது\n"
                    "4) எனது இயக்குனரை மதிப்பீடு செய்யவும்\n"
                    "5) வெளியேறு"
          });
        } else if (input == '4') {
          addMessage(
              "உங்கள் இயக்குனரை மதிப்பீடு செய்ய, பயன்பாட்டின் மூலம் முடிவு செய்யவும்.");
          messages.insert(0, {
            "data": 0,
            "message":
                "நீங்கள் தமிழ் மொழியை தேர்வு செய்துள்ளீர்கள். உங்கள் விருப்பங்களைத் தேர்ந்தெடுக்கவும்:\n"
                    "1) நியமனம் செய்ய எப்படி\n"
                    "2) எனது நியமனங்களை எப்படி பார்க்க வேண்டும்\n"
                    "3) எனது நியமனத்தை எப்படி அகற்றுவது\n"
                    "4) எனது இயக்குனரை மதிப்பீடு செய்யவும்\n"
                    "5) வெளியேறு"
          });
        } else if (input == '5') {
          resetAssistant();
        } else {
          addMessage("தவறான தேர்வு. சரியான விருப்பத்தைத் தேர்ந்தெடுக்கவும்.");
          messages.insert(0, {
            "data": 0,
            "message":
                "நீங்கள் தமிழ் மொழியை தேர்வு செய்துள்ளீர்கள். உங்கள் விருப்பங்களைத் தேர்ந்தெடுக்கவும்:\n"
                    "1) நியமனம் செய்ய எப்படி\n"
                    "2) எனது நியமனங்களை எப்படி பார்க்க வேண்டும்\n"
                    "3) எனது நியமனத்தை எப்படி அகற்றுவது\n"
                    "4) எனது இயக்குனரை மதிப்பீடு செய்யவும்\n"
                    "5) வெளியேறு"
          });
        }
        break;
    }
  }

  void resetAssistant() {
    setState(() {
      messages.clear();
      selectedLanguage = null;
      isGreetingDisplayed = false;
    });
    handleInput('');
  }

  void addMessage(String message) {
    setState(() {
      messages.insert(0, {"data": 0, "message": message});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Waste Assistant',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: Text(
              "Today, ${DateFormat("Hm").format(DateTime.now())}",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) => chat(
                messages[index]["message"].toString(),
                messages[index]["data"],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 5.0, color: Colors.greenAccent),
          Container(
            child: ListTile(
              leading: IconButton(
                icon: const Icon(Icons.camera_alt,
                    color: Colors.greenAccent, size: 35),
                onPressed: () {
                  // Placeholder for camera action
                  print("Camera button pressed");
                },
              ),
              title: Container(
                height: 35,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Color.fromRGBO(220, 220, 220, 1),
                ),
                padding: const EdgeInsets.only(left: 15),
                child: TextFormField(
                  controller: messageInsert,
                  decoration: const InputDecoration(
                    hintText: "Enter a Message...",
                    hintStyle: TextStyle(color: Colors.black26),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  onFieldSubmitted: (value) {
                    handleInput(value);
                    messageInsert.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.send,
                    size: 30.0, color: Colors.greenAccent),
                onPressed: () {
                  if (messageInsert.text.isEmpty) {
                    print("Empty message");
                  } else {
                    handleInput(messageInsert.text);
                    messageInsert.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to create chat bubbles
  Widget chat(String message, int data) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Bubble(
        radius: const Radius.circular(15.0),
        color: data == 0 ? Colors.greenAccent : Colors.orangeAccent,
        elevation: 0.0,
        alignment: data == 0 ? Alignment.topLeft : Alignment.topRight,
        nip: data == 0 ? BubbleNip.leftBottom : BubbleNip.rightBottom,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
