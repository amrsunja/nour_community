import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../utils/typedefs.dart';

class DownloadFileRequestParams extends Equatable {
	const DownloadFileRequestParams({
		required this.url,
		required this.savePath,
		this.onReceiveProgress,
		this.queryParams,
		this.cancelToken,
		this.data,
		this.options,
	});

	final String url;
	final String savePath;
	final Function(int count, int total)? onReceiveProgress;
	final QueryParams? queryParams;
	final CancelToken? cancelToken;
	final Object? data;
	final Options? options;

  @override
	List<Object?> get props => [
		savePath, onReceiveProgress, queryParams, cancelToken
	];
}
