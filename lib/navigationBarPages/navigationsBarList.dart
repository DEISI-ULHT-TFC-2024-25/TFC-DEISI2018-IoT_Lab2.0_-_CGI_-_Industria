import 'package:flutter/material.dart';
import 'package:tfc_industria/navigationBarPages/all.dart';
import 'package:tfc_industria/navigationBarPages/base.dart';
import 'package:tfc_industria/navigationBarPages/controller.dart';
import 'package:tfc_industria/navigationBarPages/home.dart';

final navigationsBarList = [
  (title: 'Home', icon: Icons.home , widget: HomePage()),
  (title: 'Base', icon: Icons.memory_outlined , widget: BasePage()),
  (title: 'Controller', icon: Icons.gamepad , widget: ControllerPage()),
  (title: 'All', icon: Icons.home , widget: AllPage()),
];