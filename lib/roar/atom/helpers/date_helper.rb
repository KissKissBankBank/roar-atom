module Roar
  module Atom
    class DateHelper
      def self.to_rfc3339(date)
        unless is_date?(date)
          fail TypeError, "#{date} is not an instance of Date, DateTime or Time"
        end

        return date.to_datetime.rfc3339 if date.kind_of?(Time)

        date.rfc3339
      end

      def self.is_format_rfc3339?(value)
        return unless value.kind_of?(String)

        regexp = /((\d{2,4})-?){3}T((\d{2}):?){3}(\+((\d{2}):?){2}|Z)+/
        match  = value.match(regexp)

        match && match[0] == value
      end

      def self.is_date?(value)
        value.kind_of?(Time) ||
          value.kind_of?(Date) ||
          value.kind_of?(DateTime)
      end
    end
  end
end
