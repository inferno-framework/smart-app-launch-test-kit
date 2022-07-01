# 0.1.4

Note: This kit contains separate suites for both the STU1 and STU2 versions of the SMART App Launch Framework. However, development is ongoing and the SMART STU2 suite is not yet fully complete. 

* Create separate TestSuites for containing SMART STU1 and STU2.
* Include additional field requirements for Well-known configuration tests in SMART STU2 suite.
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
