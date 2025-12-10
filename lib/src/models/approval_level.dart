class ApprovalLevel {
  String id;
  String name;
  String approvalType; // eg "requesterManager" | "specificRole" | "basedOnField"
  List<String> approvers; // store user ids or role ids (mock)
  ApprovalLevel({
    required this.id,
    required this.name,
    this.approvalType = 'specificRole',
    List<String>? approvers,
  }) : approvers = approvers ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'approvalType': approvalType,
      'approvers': approvers,
    };
  }
}
