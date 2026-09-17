import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitako_mobile/theme/app_colors.dart';
import 'package:sitako_mobile/theme/app_theme.dart';
import 'package:sitako_mobile/widgets/index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppButton', () {
    testWidgets('renders button text and triggers onPressed callback',
        (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AppButton(
            text: 'Submit',
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator and disables onTap when isLoading is true',
        (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AppButton(
            text: 'Submit',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);

      await tester.tap(find.byType(CircularProgressIndicator));
      expect(pressed, isFalse);
    });

    testWidgets('renders icon and trailing icon properly', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const AppButton(
            text: 'Search',
            icon: Icon(Icons.search),
            trailingIcon: Icon(Icons.arrow_forward),
          ),
        ),
      );

      expect(find.text('Search'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('supports different variants', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const Column(
            children: [
              AppButton(text: 'Primary', variant: AppButtonVariant.primary),
              AppButton(text: 'Dark', variant: AppButtonVariant.dark),
              AppButton(text: 'Secondary', variant: AppButtonVariant.secondary),
              AppButton(text: 'Danger', variant: AppButtonVariant.danger),
              AppButton(text: 'Outline', variant: AppButtonVariant.outline),
            ],
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
    });
  });

  group('AppBadge', () {
    testWidgets('renders label and supports different variants', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const Column(
            children: [
              AppBadge(label: 'Mustard', variant: AppBadgeVariant.mustard),
              AppBadge(label: 'Warning', variant: AppBadgeVariant.warning),
              AppBadge(label: 'Success', variant: AppBadgeVariant.success),
              AppBadge(label: 'Danger', variant: AppBadgeVariant.danger),
              AppBadge(label: 'Info', variant: AppBadgeVariant.info),
              AppBadge(label: 'Neutral', variant: AppBadgeVariant.neutral),
            ],
          ),
        ),
      );

      expect(find.text('Mustard'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
    });

    testWidgets('renders dot and icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const AppBadge(
            label: 'Active',
            showDot: true,
            icon: Icon(Icons.check, size: 12),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('AppCard & AppAccentCard', () {
    testWidgets('AppCard renders child and responds to tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('AppAccentCard renders child with top accent bar', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AppAccentCard(
            accentColor: AppColors.mustard,
            onTap: () => tapped = true,
            child: const Text('Accent Content'),
          ),
        ),
      );

      expect(find.text('Accent Content'), findsOneWidget);
      await tester.tap(find.text('Accent Content'));
      expect(tapped, isTrue);
    });
  });

  group('AppTextField', () {
    testWidgets('renders label, hint, and handles input changes', (tester) async {
      var enteredValue = '';

      await tester.pumpWidget(
        wrapWithTheme(
          AppTextField(
            labelText: 'Email Address',
            hintText: 'Enter your email',
            onChanged: (val) => enteredValue = val,
          ),
        ),
      );

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(enteredValue, equals('test@example.com'));
    });

    testWidgets('renders error text when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const AppTextField(
            labelText: 'Password',
            errorText: 'Password is required',
          ),
        ),
      );

      expect(find.text('Password is required'), findsOneWidget);
    });
  });

  group('AppAlert', () {
    testWidgets('renders title, description, and action button', (tester) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AppAlert(
            variant: AppAlertVariant.info,
            title: 'Information',
            description: 'This is an informative message.',
            action: TextButton(
              onPressed: () => actionTriggered = true,
              child: const Text('Action'),
            ),
          ),
        ),
      );

      expect(find.text('Information'), findsOneWidget);
      expect(find.text('This is an informative message.'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);

      await tester.tap(find.text('Action'));
      expect(actionTriggered, isTrue);
    });
  });

  group('AppModal', () {
    testWidgets('showConfirmDialog returns true when confirmed and false when canceled',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await AppModal.showConfirmDialog(
                  ctx,
                  title: 'Confirm Delete',
                  message: 'Are you sure?',
                  confirmText: 'Delete',
                  cancelText: 'Cancel',
                  isDestructive: true,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      // Open Dialog again and confirm
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('showBottomSheet renders content and can be closed',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                AppModal.showBottomSheet<void>(
                  ctx,
                  title: 'Modal Sheet Title',
                  child: const Text('Sheet Content Here'),
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Sheet Title'), findsOneWidget);
      expect(find.text('Sheet Content Here'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Content Here'), findsNothing);
    });
  });
}
