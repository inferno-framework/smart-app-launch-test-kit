module SMARTAppLaunch
  class ScopeRequestsAttestationTest < Inferno::Test
    title 'Follows guidelines for scope requests'
    id :scope_requests
    description %(
      Client applications adhere to the follow guidelines for scope requests:
      - Includes a query string suffix to existing scopes, starting with `?` and followed by a series of `param=value`
        items separated by `&` in requests for a scope that applies to a subset of instances of a resource type
      - Follows the scope language which is the following sequence of characters
        - one of "patient", "user", or "system"
        - either a FHIR resource type or "*"
        - "."
        - optional "c"
        - optional "r"
        - optional "u"
        - optional "d"
        - optional "s"
        - optional "?" followed by at least 1 "<param>=<value>" pairs, where <param> is a valid search parameter and
          <value> is a valid corresponding value, with each pair each separated by "&" if there are multiple
      - Starts the query string with `patient/` for requests for patient-specific scopes
      - Starts the query string with `user/` for requests for user-level scopes
      - Starts the query string with `system/` for requests for system-level scopes
      - Includes a wildcard (`*`) for the FHIR resource for Wildcard scopes
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@132',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@135',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@137',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@141',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@143',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@146'

    input :scope_request_guidelines,
          title: 'Follows guidelines for requesting context data',
          description: %(
            I attest that the client application adheres to the following guidelines for scope requests:
            - Includes a query string suffix to existing scopes, starting with `?` and followed by a series of `param=value`
              items separated by `&` in requests for a scope that applies to a subset of instances of a resource type
            - Follows the scope language which is the following sequence of characters
              - one of "patient", "user", or "system"
              - either a FHIR resource type or "*"
              - "."
              - optional "c"
              - optional "r"
              - optional "u"
              - optional "d"
              - optional "s"
              - optional "?" followed by at least 1 "<param>=<value>" pairs, where <param> is a valid search parameter and
                <value> is a valid corresponding value, with each pair each separated by "&" if there are multiple
            - Starts the query string with `patient/` for requests for patient-specific scopes
            - Starts the query string with `user/` for requests for user-level scopes
            - Starts the query string with `system/` for requests for system-level scopes
            - Includes a wildcard (`*`) for the FHIR resource for Wildcard scopes
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :scope_request_guidelines_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert scope_request_guidelines == 'true',
             'Client application did not follow guidelines for scope requests.'
      pass scope_request_guidelines_note if scope_request_guidelines_note.present?
    end
  end
end