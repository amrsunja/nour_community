import 'package:flutter/material.dart';

class AppSnackbarWidget extends SnackBar {
	AppSnackbarWidget.sucess(
		String message, {
		super.key,
		}) : super(
		content: Placeholder(),
		elevation: 0,
		behavior: SnackBarBehavior.floating,
		backgroundColor: Colors.transparent
	);

	AppSnackbarWidget.info(
		String message, {
		super.key,
		}) : super(
		content: Placeholder(),
		elevation: 0,
		behavior: SnackBarBehavior.floating,
		backgroundColor: Colors.transparent
	);

	AppSnackbarWidget.error(
		String message, {
		super.key,
	}) : super(
		content: Placeholder(),
		elevation: 0,
		behavior: SnackBarBehavior.floating,
		backgroundColor: Colors.transparent
	);
}
