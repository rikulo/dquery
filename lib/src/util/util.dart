part of dquery;

// TODO: shall move to commons later

_fallback(a, b()) => a != null ? a : b();

final int _RAND_INT_MAX = 1000 * 1000 * 1000;
Random _r;

int _max(List<int> nums) {
  if (nums.isEmpty)
    return null;
  num m;
  for (int n in nums)
    m = m == null ? n : n > m ? n : m;
  return m;
}



// html //

bool _hasAction(Node node, String name) {
  // TODO
  return false;
}

void _performAction(Node node, String name) {
  // TODO
}
