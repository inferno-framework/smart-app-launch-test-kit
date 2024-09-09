module SMARTAppLaunch
  module TokenPayloadValidation
    STRING_FIELDS = ['access_token', 'token_type', 'scope', 'refresh_token'].freeze
    NUMERIC_FIELDS = ['expires_in'].freeze

    # All resource types from DSTU3, STU3, R4, R4B, and R5
    FHIR_RESOURCE_TYPES = [
      'Account', 'ActivityDefinition', 'ActorDefinition',
      'AdministrableProductDefinition', 'AdverseEvent', 'AllergyIntolerance',
      'Appointment', 'AppointmentResponse', 'ArtifactAssessment', 'AuditEvent',
      'Basic', 'Binary', 'BiologicallyDerivedProduct',
      'BiologicallyDerivedProductDispense', 'BodySite', 'BodyStructure',
      'Bundle', 'CapabilityStatement', 'CarePlan', 'CareTeam', 'CatalogEntry',
      'ChargeItem', 'ChargeItemDefinition', 'Citation', 'Claim',
      'ClaimResponse', 'ClinicalImpression', 'ClinicalUseDefinition',
      'CodeSystem', 'Communication', 'CommunicationRequest',
      'CompartmentDefinition', 'Composition', 'ConceptMap', 'Condition',
      'ConditionDefinition', 'Conformance', 'Consent', 'Contract', 'Coverage',
      'CoverageEligibilityRequest', 'CoverageEligibilityResponse',
      'DataElement', 'DetectedIssue', 'Device', 'DeviceAssociation',
      'DeviceComponent', 'DeviceDefinition', 'DeviceDispense', 'DeviceMetric',
      'DeviceRequest', 'DeviceUsage', 'DeviceUseRequest', 'DeviceUseStatement',
      'DiagnosticOrder', 'DiagnosticReport', 'DocumentManifest',
      'DocumentReference', 'EffectEvidenceSynthesis', 'EligibilityRequest',
      'EligibilityResponse', 'Encounter', 'EncounterHistory', 'Endpoint',
      'EnrollmentRequest', 'EnrollmentResponse', 'EpisodeOfCare',
      'EventDefinition', 'Evidence', 'EvidenceReport', 'EvidenceVariable',
      'ExampleScenario', 'ExpansionProfile', 'ExplanationOfBenefit',
      'FamilyMemberHistory', 'Flag', 'FormularyItem', 'GenomicStudy', 'Goal',
      'GraphDefinition', 'Group', 'GuidanceResponse', 'HealthcareService',
      'ImagingManifest', 'ImagingObjectSelection', 'ImagingSelection',
      'ImagingStudy', 'Immunization', 'ImmunizationEvaluation',
      'ImmunizationRecommendation', 'ImplementationGuide', 'Ingredient',
      'InsurancePlan', 'InventoryItem', 'InventoryReport', 'Invoice', 'Library',
      'Linkage', 'List', 'Location', 'ManufacturedItemDefinition', 'Measure',
      'MeasureReport', 'Media', 'Medication', 'MedicationAdministration',
      'MedicationDispense', 'MedicationKnowledge', 'MedicationOrder',
      'MedicationRequest', 'MedicationStatement', 'MedicinalProduct',
      'MedicinalProductAuthorization', 'MedicinalProductContraindication',
      'MedicinalProductDefinition', 'MedicinalProductIndication',
      'MedicinalProductIngredient', 'MedicinalProductInteraction',
      'MedicinalProductManufactured', 'MedicinalProductPackaged',
      'MedicinalProductPharmaceutical', 'MedicinalProductUndesirableEffect',
      'MessageDefinition', 'MessageHeader', 'MolecularSequence', 'NamingSystem',
      'NutritionIntake', 'NutritionOrder', 'NutritionProduct', 'Observation',
      'ObservationDefinition', 'OperationDefinition', 'OperationOutcome',
      'Order', 'OrderResponse', 'Organization', 'OrganizationAffiliation',
      'PackagedProductDefinition', 'Patient', 'PaymentNotice',
      'PaymentReconciliation', 'Permission', 'Person', 'PlanDefinition',
      'Practitioner', 'PractitionerRole', 'Procedure', 'ProcedureRequest',
      'ProcessRequest', 'ProcessResponse', 'Provenance', 'Questionnaire',
      'QuestionnaireResponse', 'ReferralRequest', 'RegulatedAuthorization',
      'RelatedPerson', 'RequestGroup', 'RequestOrchestration', 'Requirements',
      'ResearchDefinition', 'ResearchElementDefinition', 'ResearchStudy',
      'ResearchSubject', 'RiskAssessment', 'RiskEvidenceSynthesis', 'Schedule',
      'SearchParameter', 'Sequence', 'ServiceDefinition', 'ServiceRequest',
      'Slot', 'Specimen', 'SpecimenDefinition', 'StructureDefinition',
      'StructureMap', 'Subscription', 'SubscriptionStatus', 'SubscriptionTopic',
      'Substance', 'SubstanceDefinition', 'SubstanceNucleicAcid',
      'SubstancePolymer', 'SubstanceProtein', 'SubstanceReferenceInformation',
      'SubstanceSourceMaterial', 'SubstanceSpecification', 'SupplyDelivery',
      'SupplyRequest', 'Task', 'TerminologyCapabilities', 'TestPlan',
      'TestReport', 'TestScript', 'Transport', 'ValueSet', 'VerificationResult',
      'VisionPrescription'
    ].to_set.freeze

    FHIR_ID_REGEX = %r{[A-Za-z0-9\-\.]{1,64}(/_history/[A-Za-z0-9\-\.]{1,64})?(#[A-Za-z0-9\-\.]{1,64})?}

    def validate_required_fields_present(body, required_fields)
      missing_fields = required_fields.select { |field| body[field].blank? }
      missing_fields_string = missing_fields.map { |field| "`#{field}`" }.join(', ')
      assert missing_fields.empty?,
             "Token exchange response did not include all required fields: #{missing_fields_string}."
    end

    def validate_token_type(body)
      assert body['token_type'].casecmp('bearer').zero?, '`token_type` must be `bearer`'
    end

    def check_for_missing_scopes(requested_scopes, body)
      expected_scopes = requested_scopes.split
      new_scopes = body['scope'].split
      missing_scopes = expected_scopes - new_scopes

      warning do
        missing_scopes_string = missing_scopes.map { |scope| "`#{scope}`" }.join(', ')
        assert missing_scopes.empty?, %(
          Token exchange response did not include all requested scopes.
          These may have been denied by user: #{missing_scopes_string}.
        )
      end
    end

    def validate_scope_subset(received_scopes, original_scopes)
      extra_scopes = received_scopes.split - original_scopes.split
      assert extra_scopes.empty?, 'Token response contained scopes which are not a subset of the scope granted to the ' \
                                  "original access token: #{extra_scopes.join(', ')}"
    end

    def validate_token_field_types(body)
      STRING_FIELDS
        .select { |field| body[field].present? }
        .each do |field|
        assert body[field].is_a?(String),
               "Expected `#{field}` to be a String, but found #{body[field].class.name}"
      end

      NUMERIC_FIELDS
        .select { |field| body[field].present? }
        .each do |field|
          assert body[field].is_a?(Numeric),
                 "Expected `#{field}` to be a Numeric, but found #{body[field].class.name}"
        end
    end

    def validate_fhir_context(fhir_context)
      return if fhir_context.nil?

      assert fhir_context.is_a?(Array), "`fhirContext` field is a #{fhir_context.class.name}, but should be an Array"

      fhir_context.each do |reference|
        assert reference.is_a?(String), "`#{reference.inspect}` is not a string"
      end

      fhir_context.each do |reference|
        assert !reference.start_with?('http'), "`#{reference}` is not a relative reference"
        check_fhir_context_reference(reference)
      end
    end

    def check_fhir_context_reference(reference)
      assert reference.is_a?(String), "`#{reference.inspect}` is not a String"
      assert !reference.start_with?('http'), "`#{reference}` is not a relative reference"

      resource_type, id = reference.split('/')

      assert FHIR_RESOURCE_TYPES.include?(resource_type),
             "`#{resource_type}` in `reference` is not a valid FHIR resource type"

      assert id.match?(FHIR_ID_REGEX), "`#{id}` in `reference` is not a valid FHIR id"
    end

    def check_fhir_context_canonical(canonical)
      assert canonical.is_a?(String), "`#{canonical.inspect}` is not a String"
      assert canonical.start_with?('http'), "`#{canonical}` is not a canonical reference"

      split_canonical = canonical.split('/')

      if split_canonical.last.start_with?(/&|\|/)
        resource_type = split_canonical[-3]
        id = split_canonical[-2]
      else
        resource_type = split_canonical[-2]
        id = split_canonical.last.split(/&|\|/).first
      end

      assert FHIR_RESOURCE_TYPES.include?(resource_type),
             "`#{resource_type}` in `canonical` is not a valid FHIR resource type"

      assert id.match?(FHIR_ID_REGEX), "`#{id}` in `canonical` is not a valid FHIR id"
    end

    def check_fhir_context_identifier(identifier)
      assert identifier.is_a?(Hash), "`#{identifier.inspect}` is not an Object"
    end

    def validate_fhir_context_stu2_2(fhir_context)
      return if fhir_context.nil?

      assert fhir_context.is_a?(Array), "`fhirContext` field is a #{fhir_context.class.name}, but should be an Array"

      fhir_context.each do |reference|
        assert reference.is_a?(Hash), "`#{reference.inspect}` is not an Object"
      end

      fhir_context.each do |context|
        reference = context['reference']
        canonical = context['canonical']
        identifier = context['identifier']

        type = context['type']

        assert reference.present? || canonical.present? || identifier.present?,
               '`fhirContext` array SHALL include at least one of "reference", "canonical", or "identifier"'

        check_fhir_context_reference(reference) if reference.present?
        check_fhir_context_canonical(canonical) if canonical.present?
        check_fhir_context_identifier(identifier) if identifier.present?

        if (canonical.present? || identifier.present?) && type.blank?
          info 'The `type` field is recommended when "canonical" or "identifier" is present in `fhirContext` object'
        end

        next unless type.present?

        assert FHIR_RESOURCE_TYPES.include?(type),
               "`#{type}` in `type` is not a valid FHIR resource type"
      end
    end
  end
end
