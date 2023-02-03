import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/home/bloc/cotacts_cubit/contacts_cubit.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:flutter_chat/widgets/main_button.dart';

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MainButton(
            text: 'text',
            onPressed: () async {
              await context.read<ContactsCubit>().getUserData();
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
