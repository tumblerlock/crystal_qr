module RangeUtils
  private def flatten_ranges(ranges : Array)
    flattened = [] of Int32

    ranges.each do |range|
      case range
      when Int
        flattened << range
      when Range
        range.each do |position|
          flattened << position
        end
      end
    end

    flattened
  end
end
