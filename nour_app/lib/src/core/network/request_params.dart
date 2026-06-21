import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../utils/typedefs.dart';

class RequestParams extends Equatable {
	const RequestParams({
		this.data,
		this.queryParams,
		this.options,
		this.cancelToken,
	});

	final Object? data;
	final QueryParams? queryParams;
	final Options? options;
	final CancelToken? cancelToken;

  @override
	List<Object?> get props => [
		data,
		queryParams,
		options,
		cancelToken
	];
}
