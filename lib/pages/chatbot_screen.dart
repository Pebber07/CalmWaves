import 'package:calmwaves_app/secrets.dart';
import 'package:calmwaves_app/widgets/custom_app_bar.dart';
import 'package:calmwaves_app/widgets/custom_drawer.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

/// The Assistant screen, where the users are able to ask questions from an assistant.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 10,
      ),
    ),
    enableLog: true,
  ); // How long can our request run --> response.

  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "Norman", lastName: "Tapodi");
  final ChatUser _gptChatUser =
      ChatUser(id: "2", firstName: "Chat", lastName: "GPT");

  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.lightBlue,
            currentUserTextColor: Colors.white,
            containerColor: Colors.blue,
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getChatresponse(m);
          },
          messages:
              _messages), // currentUser: whoever the current user is, onSend: Function that will be called when we send a message, messages: messages that are in the chat.
    );
  }

  Future<void> getChatresponse(ChatMessage m) async {
    setState(
      () {
        _messages.insert(0, m);
        _typingUsers.add(_gptChatUser);
      },
    );

    List<Map<String, dynamic>> _messagesHistory = [
      {
        "role": "system",
        "content":
            "Te egy mentális egészséggel foglalkozó chatbot vagy. Csak mentális egészséggel kapcsolatos kérdésekre válaszolj.",
      },
      ..._messages.reversed.map((m) {
        if (m.user == _currentUser) {
          return {
            "role": "user",
            "content": m.text,
          };
        } else {
          return {
            "role": "assistant",
            "content": m.text,
          };
        }
      }),
    ];

    final request = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      // I got a message from GPT, and it wasn't null.
      if (element.message != null) {
        setState(
          () {
            _messages.insert(
              0,
              ChatMessage(
                  user: _gptChatUser,
                  createdAt: DateTime.now(),
                  text: element.message!.content),
            );
          },
        );
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
