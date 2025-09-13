enum BinarySearch {
    static func find(_ value: UInt32, in table: [Range<UInt32>]) -> Bool {
        if table.isEmpty || value < table[0].lowerBound {
            return false
        }

        var low = 0
        var high = table.count - 1

        while low <= high {
            let mid = (low + high) / 2
            let interval = table[mid]

            if interval.upperBound < value {
                low = mid + 1
            } else if interval.lowerBound > value {
                high = mid - 1
            } else {
                return true
            }
        }

        return false
    }
}
