# Bugfix Requirements Document

## Introduction

The password reset flow in the Flutter web client contains a critical security vulnerability where the 6-digit verification code sent to the user's email is not validated on the server before allowing the user to proceed to the password reset step. This allows any user to bypass code verification by entering an arbitrary code in the UI, creating a security risk where attackers can attempt to reset passwords without proper authorization.

The vulnerability exists in the `_verifyCode()` method of `forgot_password_screen.dart`, which only updates the UI state locally without making a server-side validation call. The code is only validated during the final password reset step, which is too late in the flow and enables potential brute-force attacks.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a user enters any 6-digit code (valid or invalid) in the password reset verification step THEN the system allows progression to the password entry step without server-side validation

1.2 WHEN a user submits the verification code THEN the system only updates local UI state (`_currentStep = _Step.password`) without calling the backend

1.3 WHEN an attacker enters random codes THEN the system provides no feedback about code validity until the final password reset attempt

### Expected Behavior (Correct)

2.1 WHEN a user enters a 6-digit code in the verification step THEN the system SHALL call a backend endpoint to verify the code before allowing progression

2.2 WHEN the verification code is invalid THEN the system SHALL display an error message and prevent progression to the password entry step

2.3 WHEN the verification code is valid THEN the system SHALL allow progression to the password entry step only after successful server-side validation

2.4 WHEN the backend validates a code THEN the system SHALL provide appropriate error messages for expired codes, invalid codes, or rate-limiting violations

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a user requests a password reset with a valid email THEN the system SHALL CONTINUE TO send a 6-digit code to that email address

3.2 WHEN a user completes all steps with valid inputs THEN the system SHALL CONTINUE TO successfully reset the password

3.3 WHEN a user submits the final password reset with an invalid code THEN the system SHALL CONTINUE TO reject the request (final validation remains as fallback)

3.4 WHEN rate limiting is triggered THEN the system SHALL CONTINUE TO enforce rate limits on password reset attempts

3.5 WHEN a user navigates through the password reset UI flow THEN the system SHALL CONTINUE TO display the same step-by-step interface
