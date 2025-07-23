module SMARTAppLaunch
  class ScopesAttestation < Inferno::Test
    title ''
    id :scopes
    description %(
      - Allows for an update operation to create a new instance by the update scope
      - Allows the client to access specific data about a single patient when granting patient-specific scopes
      - Contains documentation that describes its authorization behavior if that server supports linking one Patient
        record with another via `Patient.link`
      - Allows the client to access specific data that a user can access when granting user-level scopes
      - Allows the client to access data that a client-system is directly authorized to access when granting
        system-level scopes
      - Allows the client to access all data for all available FHIR resources, both now and in the future, when granting
        wildcard scopes
      - Are told what context parameters will be provided in the access token response by the context data scopes
      - Does not support the `fhirUser` scope if the EHR cannot represent the user with a FHIR resource
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@123',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@136',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@139',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@140',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@142',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@144',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@149',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@197'

  end
end