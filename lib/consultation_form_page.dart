import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/consultation_form_data.dart';
import 'app_state.dart';

class ConsultationFormPage extends StatefulWidget {
  const ConsultationFormPage({super.key});

  @override
  State<ConsultationFormPage> createState() => _ConsultationFormPageState();
}

class _ConsultationFormPageState extends State<ConsultationFormPage> {
  late ConsultationFormData formData;
  int currentStep = 0;
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController studentIdController;
  late TextEditingController courseProgramController;
  late TextEditingController yearLevelController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailAddressController;
  late TextEditingController subjectClassTitleController;
  late TextEditingController advisorNameController;
  late TextEditingController detailedConcernsController;
  late TextEditingController issuesDiscussedController;
  late TextEditingController actionTakenController;
  late TextEditingController recommendationsController;
  late TextEditingController studentSignatureController;

  final List<String> purposeOptions = [
    'Academic Performance',
    'Subject Clarification',
    'Wellbeing/Personal Issues',
    'Progression Advice',
  ];
  final List<String> venueOptions = ['In-person', 'Online', 'Phone', 'Email'];
  final List<String> yearLevelOptions = ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Postgraduate'];

  @override
  void initState() {
    super.initState();
    formData = ConsultationFormData();
    final appState = context.read<AppState>();
    formData.fullName = appState.displayName;
    _initControllers();
  }

  void _initControllers() {
    fullNameController          = TextEditingController(text: formData.fullName);
    studentIdController         = TextEditingController(text: formData.studentId);
    courseProgramController     = TextEditingController(text: formData.courseProgram);
    yearLevelController         = TextEditingController(text: formData.yearLevel);
    phoneNumberController       = TextEditingController(text: formData.phoneNumber);
    emailAddressController      = TextEditingController(text: formData.emailAddress);
    subjectClassTitleController = TextEditingController(text: formData.subjectClassTitle ?? '');
    advisorNameController       = TextEditingController(text: formData.advisorName);
    detailedConcernsController  = TextEditingController(text: formData.detailedConcerns);
    issuesDiscussedController   = TextEditingController(text: formData.issuesDiscussed);
    actionTakenController       = TextEditingController(text: formData.actionTaken);
    recommendationsController   = TextEditingController(text: formData.recommendations);
    studentSignatureController  = TextEditingController(text: formData.studentSignature);
  }

  @override
  void dispose() {
    for (final c in [
      fullNameController, studentIdController, courseProgramController,
      yearLevelController, phoneNumberController, emailAddressController,
      subjectClassTitleController, advisorNameController, detailedConcernsController,
      issuesDiscussedController, actionTakenController, recommendationsController,
      studentSignatureController,
    ]) { c.dispose(); }
    _pageController.dispose();
    super.dispose();
  }

  void _syncToFormData() {
    formData.fullName           = fullNameController.text;
    formData.studentId          = studentIdController.text;
    formData.courseProgram      = courseProgramController.text;
    formData.yearLevel          = yearLevelController.text;
    formData.phoneNumber        = phoneNumberController.text;
    formData.emailAddress       = emailAddressController.text;
    formData.subjectClassTitle  = subjectClassTitleController.text;
    formData.advisorName        = advisorNameController.text;
    formData.detailedConcerns   = detailedConcernsController.text;
    formData.issuesDiscussed    = issuesDiscussedController.text;
    formData.actionTaken        = actionTakenController.text;
    formData.recommendations    = recommendationsController.text;
    formData.studentSignature   = studentSignatureController.text;
    formData.facultySignature   = '';
    formData.deanSignature      = null;
  }

  void _submit() {
    _syncToFormData();
    if (formData.isFormComplete) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submit Consultation?'),
          content: const Text('Your request will be sent to your adviser for approval.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, formData);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<String> get _adviserNames {
    final state = context.read<AppState>();
    return state.adviserNames.isNotEmpty ? state.adviserNames : ['Dr. Cruz', 'Prof. Santos'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0a1e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Step ${currentStep + 1} of 5',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / 5,
                minHeight: 5,
                backgroundColor: Colors.white12,
                color: const Color(0xFFE040FB),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => currentStep = i),
              children: [
                _buildStep(_step1PersonalInfo(), '1/5', 'Pre-Consultation Form'),
                _buildStep(_step2ConsultationDetails(), '2/5', 'Consultation Details'),
                _buildStep(_step3Purpose(), '3/5', 'Purpose & Concerns'),
                _buildStep(_step4ActionPlan(), '4/5', 'Action Plan'),
                _buildStep(_step5Signature(), '5/5', 'Signature & Confirmation'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    if (currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: currentStep < 4
                          ? ElevatedButton.icon(
                        onPressed: () {
                          _syncToFormData();
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      )
                          : ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card wrapper ──────────────────────────────────────────────────────────
  Widget _buildStep(Widget content, String stepLabel, String title) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE040FB).withValues(alpha: 0.15),
                              border: Border.all(color: const Color(0xFFE040FB).withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Step $stepLabel',
                              style: const TextStyle(
                                color: Color(0xFFE040FB),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(title,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: content,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1 ────────────────────────────────────────────────────────────────
  Widget _step1PersonalInfo() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // How to consult box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF7C4DFF), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'How to consult with your adviser:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFb39dff),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...[
                  '1. Fill out and submit this form with accurate details.',
                  '2. Wait for the adviser to review and approve your request.',
                  '3. Once approved, note the scheduled date, time, and venue.',
                  '4. Attend the consultation and bring any necessary materials.',
                  '5. Follow the adviser\'s recommendations after the meeting.',
                ].map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(step,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white60, height: 1.5)),
                )),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Personal Details',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          _field(fullNameController, 'Full Name *', Icons.person),
          _field(emailAddressController, 'Email Address *', Icons.email,
              keyboardType: TextInputType.emailAddress),
          _field(studentIdController, 'Student ID *', Icons.badge),
          _field(phoneNumberController, 'Phone Number *', Icons.phone,
              keyboardType: TextInputType.phone),
          _field(courseProgramController, 'Course/Program *', Icons.school),
          _dropdown(
            value: formData.yearLevel.isEmpty ? null : formData.yearLevel,
            items: yearLevelOptions,
            label: 'Year Level *',
            onChanged: (v) => setState(() {
              formData.yearLevel = v ?? '';
              yearLevelController.text = v ?? '';
            }),
          ),
          _field(subjectClassTitleController, 'Subject/Class (Optional)', Icons.library_books),
        ],
      ),
    );
  }

  // ── Step 2 ────────────────────────────────────────────────────────────────
  Widget _step2ConsultationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datePicker(
          label: 'Date of Consultation *',
          value: formData.consultationDate,
          onSelected: (d) => setState(() => formData.consultationDate = d),
        ),
        _timePicker(
          label: 'Time of Consultation *',
          value: formData.consultationTime,
          onSelected: (t) => setState(() => formData.consultationTime = t),
        ),
        _dropdown(
          value: formData.venue,
          items: venueOptions,
          label: 'Venue/Method *',
          onChanged: (v) => setState(() => formData.venue = v ?? 'In-person'),
        ),
        DropdownButtonFormField<String>(
          initialValue: formData.advisorName.isEmpty ? null : formData.advisorName,
          decoration: InputDecoration(
            labelText: 'Select Adviser *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
          ),
          items: _adviserNames
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (v) => setState(() {
            formData.advisorName = v ?? '';
            advisorNameController.text = v ?? '';
          }),
        ),
      ],
    );
  }

  // ── Step 3 ────────────────────────────────────────────────────────────────
  Widget _step3Purpose() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select all that apply: *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        ...purposeOptions.map((p) {
          final checked = formData.purposeCategories.contains(p);
          return GestureDetector(
            onTap: () => setState(() {
              if (checked) {
                formData.purposeCategories.remove(p);
              } else {
                formData.purposeCategories.add(p);
              }
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: checked ? const Color(0xFFE040FB) : Colors.white24,
                  width: checked ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: checked ? const Color(0xFFE040FB).withValues(alpha: 0.15) : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: checked ? const Color(0xFFE040FB) : Colors.white38,
                  ),
                  const SizedBox(width: 12),
                  Text(p, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _field(detailedConcernsController, 'Detailed Concerns *', Icons.description, maxLines: 5),
      ],
    );
  }

  // ── Step 4 ────────────────────────────────────────────────────────────────
  Widget _step4ActionPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(issuesDiscussedController, 'Issues/Concerns Discussed *', Icons.chat, maxLines: 4),
        _field(actionTakenController, 'Action Taken/Agreed Upon *', Icons.checklist, maxLines: 4),
        _field(recommendationsController, 'Recommendations *', Icons.lightbulb, maxLines: 4),
      ],
    );
  }

  // ── Step 5 ────────────────────────────────────────────────────────────────
  Widget _step5Signature() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type your full name as your digital signature.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _field(studentSignatureController, 'Student Signature *', Icons.create),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 16),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By submitting, you confirm all information is accurate. '
                      'Adviser and Dean signatures will be added upon approval.',
                  style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _field(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
        ),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _datePicker({required String label, required DateTime? value, required Function(DateTime) onSelected}) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (d != null) onSelected(d);
      },
      child: _pickerBox(
        icon: Icons.calendar_today,
        label: label,
        value: value != null ? '${value.month}/${value.day}/${value.year}' : 'Tap to select',
      ),
    );
  }

  Widget _timePicker({required String label, required TimeOfDay? value, required Function(TimeOfDay) onSelected}) {
    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: value ?? TimeOfDay.now());
        if (t != null) onSelected(t);
      },
      child: _pickerBox(
        icon: Icons.access_time,
        label: label,
        value: value != null ? value.format(context) : 'Tap to select',
      ),
    );
  }

  Widget _pickerBox({required IconData icon, required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
