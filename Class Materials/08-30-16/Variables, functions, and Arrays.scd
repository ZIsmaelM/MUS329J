/****** Variables *********/
// Symbolic names beginning with a lower case
// letter, that can hold SC Objects of any kind,
// including numbers, strings, symbols, functions, arrays, etc
//
// Two types, local and global
//
// Local variables must be declared with a var statement
// and have meaning only within the block of code being
// evaluated.

(
var one = 1, two, three;
one.postln;
two = one+one;
two.postln;
three = two+one;
three.postln;
"Done!"
)

// this will also work, as long as you evaluate the entire line at once:
var foo = 500; foo.reciprocal.postln

// Global variables are known throughout the current SC
// environment (usually, the same working document).
// Once they are assigned a value, will hold that
// value indefinitely until changed, or the interpreter
// is rebooted, or a new environment is defined.
// The variables a-z are predefined for you. To create
// your own global variable, use a tilde (~) as the
// first character in the variable name.

q = 100 / 4; //the letter q is a predefined global variable name
b = "This is just a string"; //so is b
q.squared.postln; //posts the result, but does not affect q
b.postln; //b still has the string in it.
q.postln; //q still has the original value we assigned to it
q = q.squared; //this changes the value of q
q.postln;

//The lines above can be executed individually, with the same
//results and without causing errors, as long as they are evaluated
//in order. Even if they are not, most will not cause an error, because
//they are initially assigned a value of nil. But
//q.squared will cause an error, if q has never been set to anything.
//
// Example of a user-declared global variable
~my2pi = pi*2 //pi is a special reserved symbol, very useful
~my2pi.postln

/****** Assignment Statements *******/
// Variables can receive the results of various arithmetic and logical expressions

x = 20 * log10(0.5/1.0); //test that formula!
x = 100 + sqrt(0.5) * 0.5; //note: no operator precedence in SC
x = 100 + (sqrt(0.5) * 0.5); //very different result!

a = pi; b = pi + 0.1; // evaluate this line first, then try the next two
x = cos(a)+cos(b); //nice trigonometric identity here that...
x = 2.0 * cos((a + b)/2) * cos((a - b)/2); //...explains beat frequencies

x = 2.0 * cos(a+b/2) * cos(a-b/2); //same result, because no operator precedence.

/****** Functions *******/
// Functions are identified by { } ...that is,open and close curly braces
// Functions may contain lots of code, but they typically return a single value
// from a given input or set of inputs. They are very important in SuperCollider,
// because all synths that you want to execute on the server must be defined
// as functions.
// Trivial examples:
(
f = {arg x = 2;
	x**3; //return the last line (the input cubed)
})
// after evaluating this piece of code, the variable f now contains the function

f.postln; //just tells you that f is a function
f.value.postln; //gets a value from the function (use the default here)
f.value(3); //3 cubed
f.(3); //This also works (note the .) See "Syntax Shortcuts"

( //function to return the cps value of a given midi note number
g = {|midinn|
	midinn.midicps; //kind of ridiculous waste of a function!
})

g.(60).postln; //using the value shortcut again

//Much more on functions soon


/****** Collections **********/
// Many types, both ordered and unordered
// Most common type is a simple, fixed size Array.
// Can contain any kind of object and
// can be created (and filled) with a pair of
// square brackets:

[0, 2.5, 44, "one", "two", "three", \foo, \bar] //allocates and fills an array

a = Array.new(8); //allocate space for an empty array with 8 slots
a = [0, 2.5, 44, "one", "two", "three", \foo, \bar];
a.size; //SC knows the size
a.postln;

//Alternatively, saving a step:

a = Array.with(0, 2.5, 44, "one", "two", "three", \foo, \bar)

//Individual items within an array can be accessed as follows:

a[0].postln;
a[4].postln; //get the 5th item
a.at(3); //another way
a[3]; //or another

//What happens if we try to access something outside the array bounds?

a[20].postln; // no problem, just a nil
a.wrapAt(20); // exactly the same as a[20%8]
a[20%a.size].postln; //but SC knows the size of the array, so you don't need to do this.
a.foldAt(9); //7 is the last item, so fold finds "three", which is 2 back from \bar

//Here are a few other things you can do to create, fill, and get values from an array:

b = Array.series(20, 0, 5); //create a array of size 20, beginning with 0, filled with an arithmetic series
c = Array.geom(20, 1, 2); //create an array of size 20, beginning with 1, filled with powers of 2
d = Array.fill(100, { arg loc; loc**2});

//you can also plot them
b.plot("Function b");
c.plot("Function c");
d.plot("Function d");

//and there are some convenient shortcuts; (See Syntax Shortcuts in the help)
e = (0,1..10); // fill an array with a sequence of numbers, starting at location 0, adding 1 to each
e = (0, 10..100); //fill an array with a sequence of numbers, starting at location 0, adding 10 to each
//and see the help for more examples (Series Assignment to an ArrayedCollection or List)

//you also "do" an array, applying a function to the contents:
20.do({arg item, index;
	"Item ".post; index.post;"\t=\t ".post;
	 b[item].postln;}); //just posting the contents here, but could do much more

//and you can also fill and array with a function, like this:

f = Array.fill(16, {|x| x.squared;});
f.plot; //And then plot the function, via the array you have filled

