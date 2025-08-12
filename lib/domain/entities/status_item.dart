enum StatusType { image, video }

class StatusItem {
  final String filePath;
  final DateTime modifiedAt;
  final StatusType type;

  const StatusItem({
    required this.filePath,
    required this.modifiedAt,
    required this.type,
  });
}


