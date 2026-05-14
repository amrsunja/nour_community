import 'package:flutter/material.dart';

class UIBordersToken {
	const UIBordersToken();
	
	factory UIBordersToken.light() => const UIBordersToken();
	factory UIBordersToken.dark() => const UIBordersToken();

	OutlineInputBorder get textFieldUnfocusedBorder => _buildBorder(Color(0xffD5D7DA));
	OutlineInputBorder get textFieldFocusedBorder => _buildBorder(Color(0xffffffff));
	OutlineInputBorder get textFieldErrorBorder => _buildBorder(Color(0xffffffff));
	
	OutlineInputBorder _buildBorder(Color color) => OutlineInputBorder(
		borderRadius: BorderRadius.circular(8),
		borderSide: BorderSide(color: color)
	);
}
