# encoding: UTF-8
module RDF::Tabular
  ##
  # Utilities for parsing UAX35 dates and numbers.
  #
  # @see http://www.unicode.org/reports/tr35
  module UAX35

    ##
    # Parse the date format (if provided), and match against the value (if provided)
    # Otherwise, validate format and raise an error
    #
    # @param [String] format
    # @param [String] value
    # @return [String] XMLSchema version of value
    # @raise [ArgumentError] if format is not valid, or nil, if value does not match
    def parse_uax35_date(format, value)
      date_format, time_format = nil, nil
      return value unless format
      value ||= ""

      # Extract tz info
      if md = format.match(/^(.*[dyms])+(\s*[xX]+)$/)
        format, tz_format = md[1], md[2]
      end

      date_format, time_format = format.split(' ')
      date_format, time_format = nil, date_format if self.base.to_sym == :time

      # Extract date, of specified
      date_part = case date_format
      when 'yyyy-MM-dd' then value.match(/^(?<yr>\d{4})-(?<mo>\d{2})-(?<da>\d{2})/)
      when 'yyyyMMdd'   then value.match(/^(?<yr>\d{4})(?<mo>\d{2})(?<da>\d{2})/)
      when 'dd-MM-yyyy' then value.match(/^(?<da>\d{2})-(?<mo>\d{2})-(?<yr>\d{4})/)
      when 'd-M-yyyy'   then value.match(/^(?<da>\d{1,2})-(?<mo>\d{1,2})-(?<yr>\d{4})/)
      when 'MM-dd-yyyy' then value.match(/^(?<mo>\d{2})-(?<da>\d{2})-(?<yr>\d{4})/)
      when 'M-d-yyyy'   then value.match(/^(?<mo>\d{1,2})-(?<da>\d{1,2})-(?<yr>\d{4})/)
      when 'dd/MM/yyyy' then value.match(/^(?<da>\d{2})\/(?<mo>\d{2})\/(?<yr>\d{4})/)
      when 'd/M/yyyy'   then value.match(/^(?<da>\d{1,2})\/(?<mo>\d{1,2})\/(?<yr>\d{4})/)
      when 'MM/dd/yyyy' then value.match(/^(?<mo>\d{2})\/(?<da>\d{2})\/(?<yr>\d{4})/)
      when 'M/d/yyyy'   then value.match(/^(?<mo>\d{1,2})\/(?<da>\d{1,2})\/(?<yr>\d{4})/)
      when 'dd.MM.yyyy' then value.match(/^(?<da>\d{2})\.(?<mo>\d{2})\.(?<yr>\d{4})/)
      when 'd.M.yyyy'   then value.match(/^(?<da>\d{1,2})\.(?<mo>\d{1,2})\.(?<yr>\d{4})/)
      when 'MM.dd.yyyy' then value.match(/^(?<mo>\d{2})\.(?<da>\d{2})\.(?<yr>\d{4})/)
      when 'M.d.yyyy'   then value.match(/^(?<mo>\d{1,2})\.(?<da>\d{1,2})\.(?<yr>\d{4})/)
      when 'yyyy-MM-ddTHH:mm' then value.match(/^(?<yr>\d{4})-(?<mo>\d{2})-(?<da>\d{2})T(?<hr>\d{2}):(?<mi>\d{2})(?<se>(?<ms>))/)
      when 'yyyy-MM-ddTHH:mm:ss' then value.match(/^(?<yr>\d{4})-(?<mo>\d{2})-(?<da>\d{2})T(?<hr>\d{2}):(?<mi>\d{2}):(?<se>\d{2})(?<ms>)/)
      when /yyyy-MM-ddTHH:mm:ss\.S+/
        md = value.match(/^(?<yr>\d{4})-(?<mo>\d{2})-(?<da>\d{2})T(?<hr>\d{2}):(?<mi>\d{2}):(?<se>\d{2})\.(?<ms>\d+)/)
        num_ms = date_format.match(/S+/).to_s.length
        md if md && md[:ms].length <= num_ms
      else
        raise ArgumentError, "unrecognized date/time format #{date_format}" if date_format
        nil
      end

      # Forward past date part
      if date_part
        value = value[date_part.to_s.length..-1]
        value = value.lstrip if date_part && value.start_with?(' ')
      end

      # Extract time, of specified
      time_part = case time_format
      when 'HH:mm:ss' then value.match(/^(?<hr>\d{2}):(?<mi>\d{2}):(?<se>\d{2})(?<ms>)/)
      when 'HHmmss'   then value.match(/^(?<hr>\d{2})(?<mi>\d{2})(?<se>\d{2})(?<ms>)/)
      when 'HH:mm'    then value.match(/^(?<hr>\d{2}):(?<mi>\d{2})(?<se>)(?<ms>)/)
      when 'HHmm'     then value.match(/^(?<hr>\d{2})(?<mi>\d{2})(?<se>)(?<ms>)/)
      when /HH:mm:ss\.S+/
        md = value.match(/^(?<hr>\d{2}):(?<mi>\d{2}):(?<se>\d{2})\.(?<ms>\d+)/)
        num_ms = time_format.match(/S+/).to_s.length
        md if md && md[:ms].length <= num_ms
      else
        raise ArgumentError, "unrecognized date/time format #{time_format}" if time_format
        nil
      end

      # If there's a date_format but no date_part, match fails
      return nil if date_format && date_part.nil?

      # If there's a time_format but no time_part, match fails
      return nil if time_format && time_part.nil?

      # Forward past time part
      value = value[time_part.to_s.length..-1] if time_part

      # Use datetime match for time
      time_part = date_part if date_part && date_part.names.include?("hr")

      # If there's a timezone, it may optionally start with whitespace
      value = value.lstrip if tz_format.to_s.start_with?(' ')
      tz_part = case tz_format.to_s.lstrip
      when 'x'    then value.match(/^(?:(?<hr>[+-]\d{2})(?<mi>\d{2})?)$/)
      when 'X'    then value.match(/^(?:(?:(?<hr>[+-]\d{2})(?<mi>\d{2})?)|(?<z>Z))$/)
      when 'xx'   then value.match(/^(?:(?<hr>[+-]\d{2})(?<mi>\d{2}))|$/)
      when 'XX'   then value.match(/^(?:(?:(?<hr>[+-]\d{2})(?<mi>\d{2}))|(?<z>Z))$/)
      when 'xxx'  then value.match(/^(?:(?<hr>[+-]\d{2}):(?<mi>\d{2}))$/)
      when 'XXX'  then value.match(/^(?:(?:(?<hr>[+-]\d{2}):(?<mi>\d{2}))|(?<z>Z))$/)
      else
        raise ArgumentError, "unrecognized timezone format #{tz_format.to_s.lstrip}" if tz_format
        nil
      end

      # If there's a tz_format but no time_part, match fails
      return nil if tz_format && tz_part.nil?

      # Compose normalized value
      vd = ("%04d-%02d-%02d" % [date_part[:yr].to_i, date_part[:mo].to_i, date_part[:da].to_i]) if date_part
      vt = ("%02d:%02d:%02d" % [time_part[:hr].to_i, time_part[:mi].to_i, time_part[:se].to_i]) if time_part

      # Add milliseconds, if matched
      vt += ".#{time_part[:ms]}" if time_part && !time_part[:ms].empty?

      value = [vd, vt].compact.join('T')
      value += tz_part[:z] ? "Z" : ("%s:%02d" % [tz_part[:hr], tz_part[:mi].to_i]) if tz_part
      value
    end

    ##
    # Parse the date format (if provided), and match against the value (if provided)
    # Otherwise, validate format and raise an error
    #
    # @param [String] pattern
    # @param [String] value
    # @param [String] groupChar
    # @param [String] decimalChar
    # @return [String] XMLSchema version of value or nil, if value does not match
    # @raise [ArgumentError] if format is not valid
    def parse_uax35_number(pattern, value, groupChar=",", decimalChar=".")
      value ||= ""

      re = build_number_re(pattern, groupChar, decimalChar)

      # Upcase value and remove internal spaces
      value = value.upcase

      #require 'byebug'; byebug unless value.empty?
      if value =~ re

        # Upcase value and remove internal spaces
        value = value.
          upcase.
          gsub(/\s+/, '').
          gsub(groupChar, '').
          gsub(decimalChar, '.')

        # result re-assembles parts removed from value
        value
      else
        # no match
        nil
      end
    end

    # Build a regular expression from the provided pattern to match value, after suitable modifications
    #
    # @param [String] pattern
    # @param [String] groupChar
    # @param [String] decimalChar
    # @return [Regexp] Regular expression matching value
    # @raise [ArgumentError] if format is not valid
    def build_number_re(pattern, groupChar, decimalChar)
      # pattern must be composed of only 0, #, decimalChar, groupChar, E, %, and ‰
      ge = Regexp.escape groupChar
      de = Regexp.escape decimalChar

      default_pattern = /^
        ([+-]?
         [\d#{ge}]+
         (#{de}[\d#{ge}]+
          ([Ee][+-]?\d+)?
         )?[%‰]?
        |NAN|INF|-INF)
      $/x

      return default_pattern if pattern.nil?
      numeric_pattern = /
        # Mantissa
        (\#|#{ge})*
        (0|#{ge})*
        # Fractional
        (?:#{de}
          (0|#{ge})*
          (\#|#{ge})*
          # Exponent
          (E
            [+-]?
            (?:\#|#{ge})*
            (?:0|#{ge})*
          )?
        )?
      /x

      legal_number_pattern = /^(?<prefix>[^\#0]*)(?<numeric_part>#{numeric_pattern})(?<suffix>.*)$/x

      match = legal_number_pattern.match(pattern)
      raise ArgumentError, "unrecognized number pattern #{pattern}" if match["numeric_part"].empty?

      prefix, numeric_part, suffix = match["prefix"], match["numeric_part"], match["suffix"]
      prefix = Regexp.escape prefix unless prefix.empty?
      prefix += "[+-]?" unless prefix =~ /[+-]/
      suffix = Regexp.escape suffix unless suffix.empty?

      # Split on decimalChar and E
      parts = numeric_part.split("E")
      mantissa_part, exponent_part = parts[0], (parts[1] || '')

      mantissa_parts = mantissa_part.split(decimalChar)
      raise ArgumentError, "Multiple decimal separators in #{pattern}" if mantissa_parts.length > 2
      integer_part, fractional_part = mantissa_parts[0], mantissa_parts[1] || ''

      min_integer_digits = integer_part.gsub(groupChar, '').gsub('#', '').length
      all_integer_digits = integer_part.gsub(groupChar, '').length
      all_integer_digits += 1 if all_integer_digits == min_integer_digits
      min_fractional_digits = fractional_part.gsub(groupChar, '').gsub('#', '').length
      max_fractional_digits = fractional_part.gsub(groupChar, '').length
      exponent_sign = exponent_part[0] if exponent_part =~ /^[+-]/
      min_exponent_digits = exponent_part.sub(/[+-]/, '').gsub("#", "").length
      max_exponent_digits = exponent_part.sub(/[+-]/, '').length

      integer_parts = integer_part.split(groupChar)[1..-1]
      primary_grouping_size = integer_parts[-1].to_s.length
      secondary_grouping_size = integer_parts.length <= 1 ? primary_grouping_size : integer_parts[-2].length

      fractional_parts = fractional_part.split(groupChar)[0..-2]
      fractional_grouping_size = fractional_parts[0].to_s.length

      # Construct regular expression for integer part
      #require 'byebug'; byebug
      integer_str = if primary_grouping_size == 0
        "\\d{#{min_integer_digits},}"
      else
        # These number of groupings must be there
        integer_parts = []
        integer_rem = 0
        while min_integer_digits > 0
          sz = [primary_grouping_size, min_integer_digits].min
          integer_rem = primary_grouping_size - sz
          integer_parts << "\\d{#{sz}}"
          min_integer_digits -= sz
          all_integer_digits -= sz
          primary_grouping_size = secondary_grouping_size
        end
        required_digits = integer_parts.reverse.join(ge)

        if all_integer_digits > 0
          # Add digits up to end of group creating
          # (?:(?:\d)?)\d)? ...
          integer_parts = []
          while integer_rem > 0
            integer_parts << '\d'
            integer_rem -= 1
          end

          # If secondary_grouping_size is not primary_grouping_size, add digits up to secondary_grouping_size
          if secondary_grouping_size != primary_grouping_size
            primary_grouping_size = secondary_grouping_size
            integer_rem = primary_grouping_size - 1
            integer_parts << '\d' + ge

            while integer_rem > 0
              integer_parts << '\d'
              integer_rem -= 1
            end
          end

          # Allow repeated separated groups
          if integer_parts.empty?
            opt_digits = "(?:\\d{1,#{primary_grouping_size}}#{ge})?(?:\\d{#{primary_grouping_size}}#{ge})*"
          else
            integer_parts[-1] = "(?:\\d{1,#{primary_grouping_size}}#{ge})?(?:\\d{#{primary_grouping_size}}#{ge})*#{integer_parts[-1]}"
            opt_digits = integer_parts.reverse.inject("") {|memo, part| "(?:#{memo}#{part})?"}
          end

          opt_digits + required_digits
        else
          required_digits
        end
      end

      # Construct regular expression for fractional part
      fractional_str = if max_fractional_digits > 0
        if fractional_grouping_size == 0
          min_fractional_digits == max_fractional_digits ? "\\d{#{max_fractional_digits}}" : "\\d{#{min_fractional_digits},#{max_fractional_digits}}"
        else
          # These number of groupings must be there
          fractional_parts = []
          fractional_rem = 0
          while min_fractional_digits > 0
            sz = [fractional_grouping_size, min_fractional_digits].min
            fractional_rem = fractional_grouping_size - sz
            fractional_parts << "\\d{#{sz}}"
            max_fractional_digits -= sz
            min_fractional_digits -= sz
          end
          required_digits = fractional_parts.join(ge)

          # If max digits fill within existing group
          fractional_parts = []
          while max_fractional_digits > 0
            fractional_parts << (fractional_rem == 0 ? ge + '\d' : '\d')
            max_fractional_digits -= 1
            fractional_rem = (fractional_rem - 1) % fractional_grouping_size
          end

          opt_digits = fractional_parts.reverse.inject("") {|memo, part| "(?:#{part}#{memo})?"}
          required_digits + opt_digits
        end
      end.to_s
      fractional_str = de + fractional_str unless fractional_str.empty?
      fractional_str = "(?:#{fractional_str})?" if max_fractional_digits > 0 && min_fractional_digits == 0

      # Exponent pattern
      exponent_str = case
      when max_exponent_digits > 0 && max_exponent_digits == min_exponent_digits
        "E#{exponent_sign ? Regexp.escape(exponent_sign) : '[+-]?'}\\d{#{max_exponent_digits}}"
      when max_exponent_digits > 0
        "E#{exponent_sign ? Regexp.escape(exponent_sign) : '[+-]?'}\\d{#{min_exponent_digits},#{max_exponent_digits}}"
      when min_exponent_digits > 0
        "E#{exponent_sign ? Regexp.escape(exponent_sign) : '[+-]?'}\\d{#{min_exponent_digits},#{max_exponent_digits}}"
      end

      Regexp.new("^(?<prefix>#{prefix})(?<numeric_part>#{integer_str}#{fractional_str}#{exponent_str})(?<suffix>#{suffix})$")
    end
  end
end