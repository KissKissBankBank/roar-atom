module Roar
  module Atom
    class DateHelper
      def self.to_rfc3339(date)
        date.to_datetime.rfc3339
      end

      def self.is_rfc3339_format?(value)
        return unless value.kind_of?(String)

        regexp = /((\d{2,4})-?){3}T((\d{2}):?){3}(\+((\d{2}):?){2}|Z)+/
        match  = value.match(regexp)

        match && match[0] == value
      end

      # Documentation for atom date construct:
      # http://tools.ietf.org/html/rfc4287#section-3.3
      def self.format_date_element(value)
        return value if is_rfc3339_format?(value)

        to_rfc3339(value)
      end
    end
  end
end
