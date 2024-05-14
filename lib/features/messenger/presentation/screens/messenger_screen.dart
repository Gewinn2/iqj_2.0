//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iqj/features/messenger/data/chat_service.dart';
import 'package:iqj/features/messenger/presentation/screens/chat_bubble.dart';
import 'package:iqj/features/messenger/presentation/screens/group_bubble.dart';
import 'package:iqj/features/messenger/presentation/screens/highlight_chat_bubble.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerBloc();
}

class _MessengerBloc extends State<MessengerScreen> {
  bool _isSearch = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService chatService = ChatService();

  void searchfilter() {
    setState(() {
      _isSearch = !_isSearch;
    });
  }

  bool _isntSearch_chat = true;
  TextEditingController SearchPickerController = TextEditingController();

  Map<String, dynamic> userMap = {};
  Map<String, dynamic> groupMap = {};

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore
        .collection('users')
        .where("email", isEqualTo: SearchPickerController.text)
        .get()
        .then((value) {
      setState(() {
        try {
          userMap = value.docs[0].data();
        } catch (e) {
          userMap = {};
        }

        _isntSearch_chat = false;
        print(userMap);
        print(userMap['email']);
      });
    });

    await _firestore
        .collection('groups')
        .where("name", isEqualTo: SearchPickerController.text)
        .get()
        .then((value) {
      setState(() {
        try {
          groupMap = value.docs[0].data();
        } catch (e) {
          groupMap = {};
        }

        _isntSearch_chat = false;
        print(groupMap);
        print(groupMap['name']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        width: 50.0, // Задаем ширину
        height: 50.0, // Задаем высоту
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary, // Цвет кнопки
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: IconButton(
          onPressed: () {
            //Navigator.of(context).pushNamed('creategroup');
            Navigator.of(context).pushNamed(
              'creategroup',
              arguments: {
                'selected': false,
              },
            );
          },
          icon: const Icon(Icons.edit),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        toolbarHeight: 72,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: _isSearch
            ? SizedBox(
                width: 500,
                height: 45,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: SearchPickerController,
                    decoration: InputDecoration(
                      hintText: "Поиск по заголовку...",
                      hintFadeDuration: const Duration(milliseconds: 100),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      hintStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                        height: 5,
                        color: Color.fromRGBO(128, 128, 128, 0.6),
                      ),
                      suffixIcon: SizedBox(
                        child: IconButton(
                          icon: const Icon(
                            Icons.search,
                          ),
                          onPressed: () {
                            onSearch();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Text(
                'Чаты',
                style: Theme.of(context).textTheme.titleLarge,
              ),
        centerTitle: false,
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    searchfilter();
                  },
                  icon: const Icon(Icons.search),
                ),
                PopupMenuButton<String>(
                  onSelected: (String choice) {},
                  itemBuilder: (BuildContext context) {
                    return {'Настройки', 'Статус'}.map((String choice) {
                      return choice == "Настройки"
                          ? PopupMenuItem<String>(
                              value: choice,
                              child: Row(
                                children: [
                                  const Icon(Icons.settings_outlined),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                  ),
                                  Text(choice),
                                ],
                              ),
                            )
                          : PopupMenuItem<String>(
                              value: choice,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.tag_faces_sharp,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                  ),
                                  Text(choice),
                                ],
                              ),
                            );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.only(bottom: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                const Padding(padding: EdgeInsets.only(right: 12)),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  child: const Text('Все'),
                ),
                const Padding(padding: EdgeInsets.only(right: 6)),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    //backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primaryContainer),
                  ),
                  child: const Text('Группы'),
                ),
                const Padding(padding: EdgeInsets.only(right: 6)),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    //backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primaryContainer),
                  ),
                  child: const Text('Студенты'),
                ),
                const Padding(padding: EdgeInsets.only(right: 6)),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    //backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primaryContainer),
                  ),
                  child: const Text('Преподаватели'),
                ),
                const Padding(padding: EdgeInsets.only(right: 6)),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    //backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primaryContainer),
                  ),
                  child: const Text('Руководство'),
                ),
                const Padding(padding: EdgeInsets.only(right: 6)),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    //backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primaryContainer),
                  ),
                  child: const Text('Прочее'),
                ),
                const Padding(padding: EdgeInsets.only(right: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                // Чат текущей пары
                const HighlightChatBubble(
                  imageUrl:
                      'https://gas-kvas.com/grafic/uploads/posts/2023-10/1696557271_gas-kvas-com-p-kartinki-vulkan-9.jpg',
                  chatTitle: 'GroupName',
                  secondary: 'secondaryText',
                ),
                if (_isntSearch_chat)
                  _chatsBuilder()
                else if (userMap.isNotEmpty)
                  ChatBubble(
                    imageUrl: userMap['picture'].toString(),
                    chatTitle: userMap['email'].toString(),
                    secondary: 'text',
                    uid: userMap['uid'].toString(),
                  )
                else if (groupMap.isNotEmpty)
                  GroupBubble(
                    imageUrl: groupMap['picture'].toString(),
                    chatTitle: groupMap['name'].toString(),
                    secondary: '',
                    id: groupMap['id'].toString(),
                  )
                else
                  Align(
                    child: Text("чат не найден"),
                  )
                // ignore: unnecessary_null_comparison
                // Чат обычный
                // ChatBubble(
                //     imageUrl:
                //         'https://static.wikia.nocookie.net/half-life/images/0/00/Gordonhl1.png/revision/latest/scale-to-width/360?cb=20230625151406&path-prefix=en',
                //     chatTitle: 'Денис',
                //     secondary: 'secondaryText',),
                // ChatBubble(
                //     imageUrl:
                //         'https://static.wikia.nocookie.net/half-life/images/0/00/Gordonhl1.png/revision/latest/scale-to-width/360?cb=20230625151406&path-prefix=en',
                //     chatTitle: 'Стас',
                //     secondary: 'secondaryText',),
                // ChatBubble(
                //     imageUrl:
                //         'https://static.wikia.nocookie.net/half-life/images/0/00/Gordonhl1.png/revision/latest/scale-to-width/360?cb=20230625151406&path-prefix=en',
                //     chatTitle: 'АPI',
                //     secondary: 'secondaryText',),
                // ChatBubble(
                //     imageUrl:
                //         'https://static.wikia.nocookie.net/half-life/images/0/00/Gordonhl1.png/revision/latest/scale-to-width/360?cb=20230625151406&path-prefix=en',
                //     chatTitle: 'Gewin',
                //     secondary: 'secondaryText',),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatsBuilder() {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').get(),
        FirebaseFirestore.instance.collection('groups').get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error fetching chats');
        }

        List<Widget> chatList = [];

        // Load direct messages
        chatList.addAll(snapshot.data![0].docs
            .map<Widget>((doc) => _buildChatListItem(doc)));

        // Load group chats
        snapshot.data![1].docs.forEach((groupDoc) {
          final Map<String, dynamic> groupData =
              groupDoc.data() as Map<String, dynamic>;
          String groupId = groupDoc.id;
          String groupName = groupData['name'].toString();

          chatList.add(GroupBubble(
            imageUrl: 'nonononoWAITWAITWAITWAIT',
            chatTitle: groupName,
            secondary: '...',
            id: groupId,
          ));
        });

        return Column(
          children: chatList,
        );
      },
    );
  }

  Widget _buildChatListItem(DocumentSnapshot document) {
  final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
  final ChatService _chatService = ChatService();
  String last_message='';

  // _chatService.getLastMessage(_auth.currentUser!.uid, data['uid'].toString()).then((String lastMessage) {
  //   // Здесь устанавливаем значение last_message после завершения асинхронной операции
  //   setState(() {
  //     last_message = lastMessage;
  //   });
  // }).catchError((error) {
  //   // Обработка возможных ошибок
  //   setState(() {
  //     last_message = ''; // Устанавливаем значение по умолчанию или обработку ошибки
  //   });
  // });

  // Остальной код метода
  if (_auth.currentUser!.email != data['email']) {
    return ChatBubble(
      imageUrl: data['picture'].toString(),
      chatTitle: data['email'].toString(),
      secondary: last_message ?? '', // Используйте значение по умолчанию или обработку неопределенного значения
      uid: data['uid'].toString(),
    );
  }
  return ChatBubble(
    imageUrl: data['picture'].toString(),
    chatTitle: 'Заметки',
    secondary: last_message ?? '',
    uid: data['uid'].toString(),
  );
}

}
