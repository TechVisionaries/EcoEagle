import 'package:dialogflow_flutter_plus/dialogflowFlutter.dart';
import 'package:dialogflow_flutter_plus/googleAuth.dart';
import 'package:dialogflow_flutter_plus/language.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  void response(query) async {
    try {
      print(query);
      AuthGoogle authGoogle =
          await AuthGoogle(fileJson: "assets/chatBot/service.json").build();
      DialogFlow dialogflow =
          DialogFlow(authGoogle: authGoogle, language: Language.english);
      print(dialogflow);
      print(dialogflow.authGoogle);
      print(dialogflow.language);
      print(dialogflow.resetContexts);
      print(dialogflow.toString());
      print(dialogflow.detectIntent(query));
      AIResponse aiResponse = await dialogflow.detectIntent(query);

      // Check if the response is null or the message list is empty
      if (aiResponse.getListMessage() != null &&
          aiResponse.getListMessage()!.isNotEmpty) {
        setState(() {
          messsages.insert(0, {
            "data": 0,
            "message":
                aiResponse.getListMessage()![0]["text"]["text"][0].toString()
          });
        });
      } else {
        print("No valid message found in the response.");
        // Optionally, insert an error message into the chat
        setState(() {
          messsages.insert(0, {
            "data": 0,
            "message":
                "Sorry, I didn't understand that. Could you please try again?"
          });
        });
      }
    } catch (e) {
      print("Error in DialogFlow request: $e");
      setState(() {
        messsages.insert(0, {
          "data": 0,
          "message": "Sorry, something went wrong. Please try again later."
        });
      });
    }
  }

  final messageInsert = TextEditingController();
  List<Map> messsages = [];

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
          'AI Chatbot',
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
              itemCount: messsages.length,
              itemBuilder: (context, index) => chat(
                messsages[index]["message"].toString(),
                messsages[index]["data"],
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
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.send,
                    size: 30.0, color: Colors.greenAccent),
                onPressed: () {
                  if (messageInsert.text.isEmpty) {
                    print("Empty message");
                  } else {
                    setState(() {
                      messsages.insert(
                          0, {"data": 1, "message": messageInsert.text});
                    });
                    response(messageInsert.text);
                    messageInsert.clear();
                  }
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
          const SizedBox(height: 15.0),
        ],
      ),
    );
  }

  Widget chat(String message, int data) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment:
            data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          data == 0
              ? const SizedBox(
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/chatBot/robot.jpg"),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Bubble(
              radius: const Radius.circular(15.0),
              color: data == 0
                  ? const Color.fromRGBO(23, 157, 139, 1)
                  : Colors.orangeAccent,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          message,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data == 1
              ? const SizedBox(
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/chatBot/default.jpg"),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
