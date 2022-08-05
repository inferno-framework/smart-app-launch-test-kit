# 0.1.5

* Add support for creating an authorization request using POST and integrate
  this change into App Redirect Test STU2, EHR Launch Group STU2, and
  Standalone Launch Group STU2.
* Set default scopes using SMARTv2 style in the SMART STU2 suite.
* Add `ignore_missing_scopes_check` configuration option to the Token Response
  Body Test in the EHR Launch Group (STU1 and STU2) and SMART Standalone Launch
  Group (STU1 and STU2).

# 0.1.4

Note: This kit contains separate suites for both the STU1 and STU2 versions of
the SMART App Launch Framework. However, development is ongoing and the SMART
STU2 suite is not yet fully complete.

* Create separate TestSuites for containing SMART STU1 and STU2.
* Include additional field requirements for Well-known configuration tests in
  SMART STU2 suite.
* Add an Accept header to Well-known configuration request.
* Provide documentation concerning the TestGroups available in this kit.
* Require PKCE for SMART STU2 Standalone and EHR launches.
* Improve wait messages.

# 0.1.3

* Update OpenID Token Payload test to check for `sub` claim.
* Fix url creation to account for `nil` params.

# 0.1.2

* Update scope validation for token refresh to accept a subset of the originally
  granted scopes.
* Lengthen PKCE code verifier to match spec.

# 0.1.1

* Allow a custom `launch` value in redirect test.
* Update links to SMART App Launch IG.

# 0.1.0

Initial public launch
