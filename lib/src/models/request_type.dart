import 'question_field.dart';
import 'approval_level.dart';

class RequestTypeModel {
  String procedureId;
  String procedureName;
  String procedureDesc;
  int requestFormat; // 0 form, 1 letter/document
  int status; // 0 initial
  List<QuestionField> form;
  List<ApprovalLevel> levels;

  RequestTypeModel({
    required this.procedureId,
    required this.procedureName,
    required this.procedureDesc,
    this.requestFormat = 0,
    this.status = 0,
    List<QuestionField>? form,
    List<ApprovalLevel>? levels,
  })  : form = form ?? [],
        levels = levels ?? [];

  Map<String, dynamic> toJson() {
    return {
      'procedure_id': procedureId,
      'procedure_desc': procedureDesc,
      'procedure name': procedureName,
      'request_format': requestFormat.toString(),
      'status': status.toString(),
      'form': form.map((f) => [f.type.name, f.label, f.options.isEmpty ? '' : f.options]).toList(),
      'levels': levels.map((l) => {
        'role': '', // you can add role id
        'users': l.approvers.map((u) => {'uid': u, 'status': [], 'comment': []}).toList(),
        'net_status': '0',
      }).toList(),
    };
  }
}
