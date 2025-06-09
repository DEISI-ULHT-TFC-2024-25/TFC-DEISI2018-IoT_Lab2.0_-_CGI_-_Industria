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

    // Defina o título com base no índice selecionado
    String appBarTitle = _selectedIndex == 3
        ? "Relatorio KPI's"
        : 'Bem Vindo IoT-Insdústria   |';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appBarTitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
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
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: navigationsBarList[_selectedIndex].widget,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: navigationsBarList
            .map((pages) =>
            NavigationDestination(icon: Icon(pages.icon), label: pages.title))
            .toList(),
      ),
    );
  }
}