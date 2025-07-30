class DropdownDto {
  final int id;
  final String name;

  DropdownDto({required this.id, required this.name});
  factory DropdownDto.fromJson(Map<String, dynamic> json) {
    return DropdownDto(id: json['id'], name: json['name']);
  }
}

class DropdownWithParentDto {
  final int id;
  final String name;
  final int parentId;

  DropdownWithParentDto({required this.id, required this.name, required this.parentId});
  factory DropdownWithParentDto.fromJson(Map<String, dynamic> json) {
    return DropdownWithParentDto(id: json['id'], name: json['name'], parentId: json["parentId"]);
  }
}
