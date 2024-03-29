# DQuery

DQuery is a porting of [jQuery](http://jquery.com/) in Dart.


* [API Reference](https://pub.dev/documentation/dquery/latest/)
* [Git Repository](https://github.com/rikulo/dquery)
* [Discussion](http://stackoverflow.com/questions/tagged/rikulo)
* [Issues](https://github.com/rikulo/dquery/issues)

## Install from Dart Pub Repository

Include the following in your `pubspec.yaml`:

    dependencies:
      dquery: any

Then run the [Pub Package Manager](http://pub.dartlang.org/doc) in Dart Editor (Tool > Pub Install). If you are using a different editor, run the command
(comes with the Dart SDK):

    pub install

## Usage

You can create a query object by selector. With context provided, the query will be based on different element.

    // selects all elements containing 'active' in CSS class
	ElementQuery $elems = $('.active');
	
	// selects all descendant elements of div containing 'active' in CSS class
	ElementQuery $elems = $('.active', div);

It implements List<Element>.

	$('.active')[0];
	$('.active').isEmpty;
	for (Element e in $('.active')) { ... }

Create another query object with traversing API, including [find](https://pub.dev/documentation/dquery/latest/dquery/Query/find.html), [closest](https://pub.dev/documentation/dquery/latest/dquery/ElementQuery/closest.html), [parent](https://pub.dev/documentation/dquery/latest/dquery/ElementQuery/parent.html), [children](https://pub.dev/documentation/dquery/latest/dquery/ElementQuery/children.html).

	$('.active').closest('ul');
	$('#myDiv').find('a.btn');

Manipulate selected elements.

	$('.active').removeClass('active');
	$('.fade').hide();

Register event handlers on queried elements, or trigger an event by API.

	$('#myBtn').on('click', (QueryEvent e) {
		...
	});
	$('#myBtn').trigger('click', data: 'my data');

There are query objects of `Document` and `Window` too.

	Query $doc = $document();
	Query $win = $window();

Check the [API reference](https://pub.dev/documentation/dquery/latest/dquery/dquery-library.html) for more features.

## Comparison to jQuery

See [here](https://github.com/rikulo/dquery/blob/master/doc/Comparison.md).

## Notes to Contributors

### Test and Debug

You are welcome to submit [bugs and feature requests](https://github.com/rikulo/dquery/issues). Or even better if you can fix or implement them!

### Fork DQuery

If you'd like to contribute back to the core, you can [fork this repository](https://help.github.com/articles/fork-a-repo) and send us a pull request, when it is ready.

Please be aware that one of Rikulo's design goals is to keep the sphere of API as neat and consistency as possible. Strong enhancement always demands greater consensus.

If you are new to Git or GitHub, please read [this guide](https://help.github.com/) first.

## Who Uses

* [Quire](https://quire.io) - a simple, collaborative, multi-level task management tool.
* [Keikai](https://keikai.io) - a sophisticated spreadsheet for big data
