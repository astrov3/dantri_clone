class DialogflowResponse {
  final String fulfillmentText;
  final List<FulfillmentMessage> fulfillmentMessages;
  final String source;
  final String? session;
  final List<OutputContext>? outputContexts;

  DialogflowResponse({
    required this.fulfillmentText,
    required this.fulfillmentMessages,
    required this.source,
    this.session,
    this.outputContexts,
  });

  factory DialogflowResponse.fromJson(Map<String, dynamic> json) {
    return DialogflowResponse(
      fulfillmentText: json['fulfillmentText'] ?? '',
      fulfillmentMessages:
          (json['fulfillmentMessages'] as List?)
              ?.map((msg) => FulfillmentMessage.fromJson(msg))
              .toList() ??
          [],
      source: json['source'] ?? '',
      session: json['session'],
      outputContexts:
          (json['outputContexts'] as List?)
              ?.map((ctx) => OutputContext.fromJson(ctx))
              .toList(),
    );
  }
}

class FulfillmentMessage {
  final TextMessage? text;

  FulfillmentMessage({this.text});

  factory FulfillmentMessage.fromJson(Map<String, dynamic> json) {
    return FulfillmentMessage(
      text: json['text'] != null ? TextMessage.fromJson(json['text']) : null,
    );
  }
}

class TextMessage {
  final List<String> text;

  TextMessage({required this.text});

  factory TextMessage.fromJson(Map<String, dynamic> json) {
    return TextMessage(text: List<String>.from(json['text'] ?? []));
  }
}

class OutputContext {
  final String name;
  final int lifespanCount;
  final Map<String, dynamic> parameters;

  OutputContext({
    required this.name,
    required this.lifespanCount,
    required this.parameters,
  });

  factory OutputContext.fromJson(Map<String, dynamic> json) {
    return OutputContext(
      name: json['name'] ?? '',
      lifespanCount: json['lifespanCount'] ?? 0,
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }
}
