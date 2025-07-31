module SMARTAppLaunch
  class AttestationTest338 < Inferno::Test
    title 'Attestation Test 338'
    id :attestation_test_338
    description %(
"To resolve a key to verify signatures, a FHIR authorization server SHALL follow this algorithm:

1. If the `jku` header is present, verify that the jku is whitelisted (i.e., that it matches the JWKS URL value supplied at registration time for the specified `client_id`).

a. If the jku header is not whitelisted, the signature verification fails.
b. If the jku header is whitelisted, create a set of potential keys by dereferencing the jku URL. Proceed to step 3.

2. If the `jku` header is absent, create a set of potential key sources consisting of all keys found in the registration-time JWKS or found by dereferencing the registration-time JWK Set URL. Proceed to step 3.

3. Identify a set of candidate keys by filtering the potential keys to identify the single key where the `kid` matches the value supplied in the client's JWT header, and the kty is consistent with the signature algorithm supplied in the client's JWT header (e.g., `RSA` for a JWT using an RSA-based signature, or `EC` for a JWT using an EC-based signature). If no keys match, or more than one key matches, the verification fails.

4. Attempt to verify the JWK using the key identified in step 3."
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@338'

    
  end
end