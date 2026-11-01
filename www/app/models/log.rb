module Log
  def self.info(*, **) = log(*, level: :info, **)

  def self.error(event, error = nil, **attributes)
    log(event, level: :error, **attributes, error: error)
  end

  def self.log(event, level: :info, **attributes)
    attributes = { event: event }.merge(attributes || {})
      .compact
      .map do |key, value|
        if value.is_a?(String) && !value.include?(" ") || value.is_a?(Symbol)
          "#{key}=#{value}"
        else
          "#{key}=#{value.inspect}"
        end
      end

    Rails.logger.tagged(Time.now.iso8601(4)) do
      Rails.logger.public_send(level, attributes.join(" "))
    end
  end
  private_class_method :log
end
