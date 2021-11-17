part of dquery;

// TODO: shall move to commons later

int? _max(List<int?> nums) {
  if (nums.isEmpty)
    return null;
  int? m;
  for (final n in nums)
    m = m == null ? n: n == null ? m: max(m, n);
  return m;
}

Map<K, V> _createMap<K, V>() => <K, V>{};



// html //

bool _hasAction(node, String name) {
  // TODO
  return false;
}

void _performAction(node, String name) {
  // TODO
}
