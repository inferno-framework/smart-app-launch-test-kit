require_relative 'patient_clinician_access_group/ehr_launch_clinician_access_test'
require_relative 'patient_clinician_access_group/ehr_launch_patient_access_test'
require_relative 'patient_clinician_access_group/standalone_clinician_access_test'
require_relative 'patient_clinician_access_group/standalone_patient_access_test'

module SMARTAppLaunch
  class PatientClinicianAccessAttestationGroup < Inferno::TestGroup
    id :patient_clinician_access_group
    title 'Patient and Clinician Access'

    run_as_group
    test from: :ehr_launch_clinician_access
    test from: :ehr_launch_patient_access
    test from: :standalone_clinician_access
    test from: :standalone_patient_access
  end
end
