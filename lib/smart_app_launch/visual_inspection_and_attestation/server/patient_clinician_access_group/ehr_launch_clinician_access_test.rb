module SMARTAppLaunch
  class EHRLaunchClinicianAccessAttestationTest < Inferno::Test
    title 'Supports the clinician access for EHR Launch capabilities'
    id :ehr_launch_clinician_access
    description %(
      The server supports the clinician access for EHR Launch capabilities:
      1. `launch-ehr`
      2. At least one of `client-public` or `client-confidential-symmetric`
      3. `context-ehr-patient` support
      4. `context-ehr-encounter` support
      5. `permission-user
      6. `permission-patient`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@351'

    input :ehr_launch_clinician_access_correct,
          title: 'Supports the clinician access for EHR Launch capabilities',
          description: %(
            I attest that the server supports the clinician access for EHR Launch capabilities:
            1. `launch-ehr`
            2. At least one of `client-public` or `client-confidential-symmetric`
            3. `context-ehr-patient` support
            4. `context-ehr-encounter` support
            5. `permission-user
            6. `permission-patient`
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
    input :ehr_launch_clinician_access_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert ehr_launch_clinician_access_correct == 'true',
             'Server does not support the clinician access for EHR Launch capabilities.'
      pass ehr_launch_clinician_access_note if ehr_launch_clinician_access_note.present?
    end
  end
end
