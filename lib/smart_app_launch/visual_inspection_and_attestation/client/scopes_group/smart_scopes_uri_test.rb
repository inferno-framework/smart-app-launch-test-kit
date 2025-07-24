module SMARTAppLaunch
  class SMARTScopesURIAttestationTest < Inferno::Test
    title 'Prefixes SMART scopes with `http://smarthealthit.org/fhir/scopes/`'
    id :smart_scopes_uri
    description %(
      The client application prefixes SMART scopes with `http://smarthealthit.org/fhir/scopes/` when URI representations
      are required.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@219'
  end
end
