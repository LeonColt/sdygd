import 'package:flutter/material.dart';
import 'package:sdygd/common/config.dart';
import 'package:sdygd/env/shen_te.dart';
import 'package:sdygd/main_common.dart';

void main() {
	WidgetsFlutterBinding.ensureInitialized();
	config = shenTeConfig;
	mainCommon();
	runApp( MyApp() );
}
