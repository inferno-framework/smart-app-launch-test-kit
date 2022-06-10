module SMARTAppLaunch
  class WellKnownCapabilitiesV1Test < Inferno::Test
    title 'Well-known configuration contains required fields'
    id :well_known_capabilities_v1
    input :well_known_configuration
    description %(
      The JSON from .well-known/smart-configuration contains the following
      required fields: `authorization_endpoint`, `token_endpoint`,
      `capabilities`
    )

    def required_capabilities
      {
        'authorization_endpoint' => String,
        'token_endpoint' => String,
        'capabilities' => Array
      }
    end

    run do
      skip_if well_known_configuration.blank?, 'No well-known configuration found'
      config = JSON.parse(well_known_configuration)

      required_capabilities.each do |key, type|
        assert config.key?(key), "Well-known configuration does not include `#{key}`"
        assert config[key].present?, "Well-known configuration field `#{key}` is blank"
        assert config[key].is_a?(type), "Well-known `#{key}` must be type: #{type.to_s.downcase}"
      end

      non_string_capabilities = config['capabilities'].reject { |capability| capability.is_a? String }

      assert non_string_capabilities.blank?, %(
        Well-known `capabilities` field must be an array of strings, but found
        non-string values:
        #{non_string_capabilities.map { |value| "`#{value.nil? ? 'nil' : value}`" }.join(', ')}
      )
    end
  end
end
