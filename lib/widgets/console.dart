import 'package:copy_files/app_context.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Console extends StatelessWidget {
  const Console({super.key});

  // final ScrollController _controller = ScrollController();

  // non trovo un modo pulito per eseguire lo scroll all'aggiunta di nuovi messaggi
  // void _scrollToBottom() {
  //   if(_controller.hasClients) {
  //     _controller.jumpTo(_controller.position.maxScrollExtent);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppContext>();
    var accentColor = FluentTheme.of(context).accentColor;
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: accentColor),
          color: Colors.white,
        ),
        width: double.infinity,
        child: Column(
          children: [
            Container(
              color: accentColor,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Messaggi',
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(
                        FluentIcons.copy,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: state.messages.join('\n')),
                        );
                        state.addMessage('Copiato negli appunti');
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  // controller: _controller,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) => Text(state.messages[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
