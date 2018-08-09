part of dquery;

// TODO: shall move to commons later

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
