import 'package:copy_files/app_context.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class Console extends StatelessWidget {
  const Console({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppContext>();
    //TODO: aggiungere un header alla console che contiene un titolo e il pulsante per copiare i dati, aggiungere un bordo alla console
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) => Text(state.messages[index]),
              )
            ),
            Positioned(
              right: 30,
              top: 10,
              child: IconButton(
                icon: const Icon(FluentIcons.copy),
                onPressed: () {
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
