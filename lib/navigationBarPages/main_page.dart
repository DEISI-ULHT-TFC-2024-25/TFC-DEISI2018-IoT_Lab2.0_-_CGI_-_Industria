import 'package:flutter/material.dart';
import 'package:tfc_industria/navigationBarPages/navigationsBarList.dart';

class MainPages extends StatefulWidget {
  MainPages({super.key});

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Aumenta a altura do AppBar
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            // Ajusta o título para baixo
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bem Vindo IoT-Insdústria   |',
                  style: TextStyle(
                      color: Colors.black,
                      // Ajuste para sua preferência de cor
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold), // Ajuste do tamanho do texto
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.precision_manufacturing),
                      iconSize: 20,
                      onPressed: () {
                        // Implementar mais opções
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.message_outlined),
                      iconSize: 20,
                      onPressed: () {
                        // Implementar mais opções
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent, // Torna o AppBar transparente
          elevation: 0, // Remove a sombra
        ),
      ),
      body: navigationsBarList[_selectedIndex].widget,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: navigationsBarList
            .map((pages) => NavigationDestination(
                icon: Icon(pages.icon), label: pages.title))
            .toList(),
      ),
    );
  }
}
