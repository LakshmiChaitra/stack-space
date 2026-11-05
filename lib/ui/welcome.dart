part of 'app.dart';

class WelcomeScreen extends StatefulWidget {
  final WorkspaceStore store;
  const WelcomeScreen({super.key, required this.store});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void submit() {
    if (form.currentState!.validate()) widget.store.chooseName(name.text);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: Panel(
              padding: const EdgeInsets.all(30),
              color: pastel(context, const Color(0xffeee8f2)),
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        BrandMark(),
                        SizedBox(width: 12),
                        Text(
                          'stack space',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      'Make this space yours.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'What should we call you?',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We’ll remember your name in this browser. You can change it anytime in Settings.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.7),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: name,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.givenName],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => submit(),
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        hintText: 'e.g. Chaitra',
                        counterText: '',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 23),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: submit,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                        label: const Text('Let’s build'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => widget.store.chooseName('Chaitra'),
                        child: const Text('Continue as Chaitra'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
