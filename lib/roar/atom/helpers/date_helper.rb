module Roar
  module Atom
    class DateHelper
      def self.to_rfc3339(date)
        unless date.respond_to?(:to_datetime) || date.respond_to?(:rfc3339)
          fail NoMethodError,
               "undefined method `to_datetime` or `rfc3339` for #{date}"
        end

        date = date.to_datetime if date.kind_of?(Time)

        date.rfc3339
      end

      def self.is_rfc3339_format?(value)
        return unless value.kind_of?(String)

        regexp = /((\d{2,4})-?){3}T((\d{2}):?){3}(\+((\d{2}):?){2}|Z)+/
        match  = value.match(regexp)

        match && match[0] == value
      end

      def self.format_date_element(value)
        return value if is_rfc3339_format?(value)

        to_rfc3339(value)
      end
    end
  end
end
