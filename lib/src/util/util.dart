part of dquery;

// TODO: shall move to commons later

_fallback(a, b()) => a != null ? a : b();

int _now() => new DateTime.now().millisecondsSinceEpoch;

int _randInt() => _rand.nextInt(_RAND_INT_MAX);

final int _RAND_INT_MAX = 1000 * 1000 * 1000;
Random _r;
Random get _rand => _fallback(_r, () => (_r = new Random()));



// html //

bool _hasAction(Node node, String name) {
  // TODO
  return false;
}

void _performAction(Node node, String name) {
  // TODO
}
