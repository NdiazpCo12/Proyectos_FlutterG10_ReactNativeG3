/// Represents one parsed row from the Brightspace CSV export.
/// CSV columns (0-indexed):
/// 0: Group Category Name
/// 1: Group Name
/// 2: Group Code
/// 3: Username
/// 4: OrgDefinedId
/// 5: First Name
/// 6: Last Name
/// 7: Email Address
/// 8: Group Enrollment Date
class CsvRow {
  CsvRow({
    required this.groupCategoryName,
    required this.groupName,
    required this.groupCode,
    required this.username,
    required this.orgDefinedId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.enrollmentDate,
  });

  factory CsvRow.fromList(List<dynamic> cols) {
    String cell(int i) => i < cols.length ? cols[i].toString().trim() : '';
    return CsvRow(
      groupCategoryName: cell(0),
      groupName: cell(1),
      groupCode: cell(2),
      username: cell(3),
      orgDefinedId: cell(4),
      firstName: cell(5),
      lastName: cell(6),
      email: cell(7),
      enrollmentDate: cell(8),
    );
  }

  final String groupCategoryName;
  final String groupName;
  final String groupCode;
  final String username;
  final String orgDefinedId;
  final String firstName;
  final String lastName;
  final String email;
  final String enrollmentDate;
}
