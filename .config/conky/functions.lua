function conky_pad(value)
    value = conky_parse(value)
    return string.format("%3d", value)
end

function conky_truncate(value)
    value = conky_parse(value)
    return string.sub(value, 0, string.find(value, '-') - 1)
end

